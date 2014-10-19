class ProjectImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    GithubTrending.new('ruby').persist_projects if [true, false].sample # :D

    Project.all.order('updated_at ASC').limit(25).each do |project|
      RubocopWorker.perform_async(project.id, true)
    end
  end
end
