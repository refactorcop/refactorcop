require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  def perform(project_id, force_run: false)
    project = Project.find_by_id!(project_id)

    if !project.new_commits? && !force_run
      logger.info "Project ##{project_id} #{project.full_name} hasn't been updated, *noop*"
      return
    end

    logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile"
    project.update_source_files!
    logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile: DONE!"

    #run rubocop

    #capture json output

    #process json output
  end
end
