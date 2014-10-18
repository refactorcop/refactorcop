require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  #start rubocop for a given repo
  def perform(project_id, force_run: false)

    project = Project.find(project_id)

    #exit if the project is not existing
    if project.nil?
      Rails.logger.warning "Project ##{project_id} not found!"
      return nil
    end

    #check wether the project is updated since last run
    if !project.new_commits? && !force_run
      Rails.logger.info "Project ##{project_id} #{project.full_name} hasn't been updated, *noop*"
      return nil
    end

    Rails.logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile"

    Project::Download.call(project)

    Rails.logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile: DONE!"
    #run rubocop

    #capture json output

    #process json output

  end
end
