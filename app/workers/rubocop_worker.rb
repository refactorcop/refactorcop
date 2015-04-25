require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  attr_reader :project, :force_run

  def perform(project_id, force_run = false)
    @project = Project.find_by_id!(project_id)
    if force_run || project_needs_analyzing?
      Project::DownloadAndLint.call(project, logger: logger)
    end
  rescue ActiveRecord::RecordNotFound => e
    logger.error { e.message }
    logger.error { "Skipping project_id(#{project_id.inspect}), because of #{e.class.name}" }
  end

  private

  # Checks whether the project needs to be reanalyzed.
  # @return [boolean]
  def project_needs_analyzing?
    if project.linted? && !project.new_commits?
      logger.info "Project ##{project.id} #{project.full_name} hasn't been updated, *noop*"
      return false
    elsif project.rubocop_running?
      logger.info "Project ##{project.id} #{project.full_name} a worker is still running? *abort*"
      return false
    end
    true
  end
end
