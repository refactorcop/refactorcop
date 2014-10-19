require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  attr_reader :project, :tmp_dir


  def perform(project_id, force_run = false)
    @project = Project.find_by_id!(project_id)

    if !project.new_commits? && !force_run
      logger.info "Project ##{project_id} #{project.full_name} hasn't been updated, *noop*"
      return
    end

    if project.rubocop_run_started_at > project.rubocop_run_dispatched_at
      logger.info "Project ##{project_id} #{project.full_name} a worker is still running? *abort*"
      #return
    end

    project.rubocop_run_started_at = Time.now
    project.save

    @tmp_dir = Dir.mktmpdir
    begin
      logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile"
      update_source_files
      logger.info "Project ##{project_id} #{project.full_name} running rubocop"
      run_rubocop
    ensure
      FileUtils.remove_entry tmp_dir
    end

    project.rubocop_run_dispatched_at = Time.now
    project.save

    logger.info "Project ##{project_id} #{project.full_name} done in #{project.rubocop_run_dispatched_at - project.rubocop_run_started_at}s"

  end

  # Imports the projects code from GitHub. Stores code in {SourceFile#content}.
  # @return [undefined]
  def update_source_files
    github_repository_data = project.fetch_github_repository_data
    Project::Download.call(project, tmp_dir)
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
      sf = SourceFile.where(project: project, path: files_json[:path]).first

      if sf.nil?
        logger.warn { "SourceFile record could not be found" }
        return
      end

      files_json[:offenses].each do |offense_json|
        sf.rubocop_offenses.create({
          severity:   offense_json[:severity],
          message:    offense_json[:message],
          cop_name:   offense_json[:cop_name],
          location_column:  offense_json[:location][:column],
          location_line:    offense_json[:location][:line],
          location_length:  offense_json[:location][:length],
        })
      end
  end

end
