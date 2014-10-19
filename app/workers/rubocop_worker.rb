require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  def perform(project_id, force_run = false)
    project = Project.find_by_id!(project_id)

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

    logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile"
    project.update_source_files!
    logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile: DONE!"

    project.rubocop_run_dispatched_at = Time.now
    project.save

    logger.info "Project ##{project_id} #{project.full_name} done in #{project.rubocop_run_started_at - project.rubocop_run_dispatched_at}s"


  end
end
