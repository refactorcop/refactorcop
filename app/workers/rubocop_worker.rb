require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  attr_reader :project, :force_run

  def perform(project_id, force_run = false)
    @project = Project.find_by_id!(project_id)
    @force_run = force_run
    return unless project_needs_analyzing?
    Project::DownloadAndLint.call(project, logger: logger)
  end

  private

  # Checks whether the project needs to be reanalyzed.
  # @return [boolean]
  def project_needs_analyzing?
    if project.linted? && !project.new_commits? && !force_run
      logger.info "Project ##{project.id} #{project.full_name} hasn't been updated, *noop*"
      return false
    elsif project.rubocop_running?
      logger.info "Project ##{project.id} #{project.full_name} a worker is still running? *abort*"
      return false
    end
    true
  end
end
