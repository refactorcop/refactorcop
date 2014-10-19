class ProjectImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    GithubTrending.new('ruby').persist_projects if [true, false].sample # :D

    Project.all.order('random()').limit(60).each do |project|
      RubocopWorker.perform_async(project.id)
    end
  end
end
