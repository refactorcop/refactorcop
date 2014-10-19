require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  attr_reader :project, :tmp_dir, :force_run


  def perform(project_id, force_run = false)
    @project = Project.find_by_id!(project_id)
    @force_run = force_run

    return unless project_needs_analyzing?

    @tmp_dir = Dir.mktmpdir

    project.update_attribute(:rubocop_run_started_at, Time.now)
    analyze_project
    project.update_attribute(:rubocop_last_run_at, Time.now)

    logger.info "Project ##{project.id} #{project.full_name} done in #{project.rubocop_last_run_at - project.rubocop_run_started_at}s"
  end

  # Checks whether the project needs to be reanalyzed.
  # @return [boolean]
  def project_needs_analyzing?
    if !project.new_commits? && !force_run
      logger.info "Project ##{project.id} #{project.full_name} hasn't been updated, *noop*"
      return false
    elsif project.rubocop_running?
      logger.info "Project ##{project.id} #{project.full_name} a worker is still running? *abort*"
      return false
    end
    true
  end

  def analyze_project
    begin
      logger.info "Project ##{project.id} #{project.full_name} fetching project zipfile"
      update_source_files
      logger.info "Project ##{project.id} #{project.full_name} running rubocop"
      run_rubocop
      logger.info "Project ##{project.id} #{project.full_name} updating project stats"
      update_project_stats
    ensure
      FileUtils.remove_entry tmp_dir
    end
  end

  # Imports the projects code from GitHub. Stores code in {SourceFile#content}.
  # @return [undefined]
  def update_source_files
    github_repository_data = project.fetch_github_repository_data
    Project::Download.call(project, tmp_dir, logger)
    project.update_repository_data github_repository_data
  end

  def run_rubocop
    rubocop_path = Rails.root.join(".rubocop.yml")
    json_data = `cd #{tmp_dir}; bundle exec rubocop --config "#{rubocop_path}" -f json`
    json = MultiJson.load(json_data, symbolize_keys: true)

    json[:files].each do |files_json|
      process_source_file(files_json)
    end
  end

  def process_source_file(files_json)
      source_file_id = files_json[:path].tr('\.rb','').to_i

      files_json[:offenses].each do |offense_json|
        create_offense(source_file_id, offense_json)
      end
  end

  def create_offense(source_file_id, offense_json)
    RubocopOffense.create({ source_file_id: source_file_id,
      severity:   offense_json[:severity],
      message:    offense_json[:message],
      cop_name:   offense_json[:cop_name],
      location_column:  offense_json[:location][:column],
      location_line:    offense_json[:location][:line],
      location_length:  offense_json[:location][:length],
    })
  end

  def update_project_stats
    project.rubocop_offenses_count = RubocopOffense.
      joins(:source_file).
      where(source_files: { project_id: project }).
      count

    project.source_files_count = project.source_files.count

  end

end
