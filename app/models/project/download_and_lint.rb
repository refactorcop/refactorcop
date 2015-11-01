# Downloads the latest source files and runs Rubocop on a project
class Project::DownloadAndLint
  include Procto.call
  attr_reader :project, :logger

  def initialize(project, logger: nil)
    @project = project
    @logger = logger || Rails.logger
  end

  def call
    update_rubocop_timestamps do
      download_latest_source_files
      run_rubocop
      update_stats
    end
  end

  private

  def update_rubocop_timestamps
    project.update_attribute(:rubocop_run_started_at, Time.now)
    yield
    project.update_attribute(:rubocop_last_run_at, Time.now)
  rescue StandardError => e
    project.update_attribute(:rubocop_run_started_at, nil)
    logger.error { "Failed to analyze project #{project.full_name.inspect}, because: #{e.inspect}" }
    raise e
  ensure
    logger.info { "Project ##{project.id} #{project.full_name} done in #{project.last_index_run_time}s" }
  end

  # Imports the projects code from GitHub. Stores code in {SourceFile#content}.
  # @return [undefined]
  def download_latest_source_files
    logger.info { "Project ##{project.id} #{project.full_name} fetching project zipfile" }
    github_repository_data = project.fetch_github_repository_data
    Project::Download.call(project, logger: logger)
    project.update_repository_data github_repository_data
  end

  def run_rubocop
    logger.info { "Project ##{project.id} #{project.full_name} running rubocop" }
    Project::RubocopRun.new(project).run
  end

  def update_stats
    logger.info { "Project ##{project.id} #{project.full_name} updating project stats" }
    project.rubocop_offenses_count = RubocopOffense.
      joins(:source_file).
      where(source_files: { project_id: project }).
      count
    project.source_files_count = project.source_files.count
    project.update_severity_counts
  end
end
