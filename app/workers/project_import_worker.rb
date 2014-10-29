class ProjectImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    GithubTrending.new('ruby').persist_projects
    lint_all Project.where(rubocop_run_started_at: nil).limit(100)
    lint_all Project.linted.order('rubocop_last_run_at ASC').limit(100)
  end

  private

  def lint_all(projects)
    projects.each do |project|
      RubocopWorker.perform_async(project.id)
    end
  end
end
