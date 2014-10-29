namespace :projects do
  desc "Import from GitHub"
  task :import => :environment do
    GithubTrending.new('ruby').persist_projects
  end

  desc "Download code and lint"
  task :lint, [:username, :name] => :environment do |_, args|
    project = Project.find_by_full_name(args[:username], args[:name])
    puts "Linting project: #{project.id} - #{project.full_name}"
    Project::DownloadAndLint.call(project)
  end

  desc "Force a run for all projects"
  task :queue_all => :environment do
    Project.all.each do |project|
      puts "Queuing project: #{project.id} - #{project.full_name}"
      RubocopWorker.perform_async(project.id, true)
    end
  end

  desc "Force a run for a given project ID"
  task :queue, [:project_id] => [:environment] do |_p, args|
    project_id = args[:project_id]
    if project_id.blank?
      puts "Please give a project_id"
      return
    end
    project = Project.find(project_id)
    puts "Queuing project: #{project.id} - #{project.full_name}"
    RubocopWorker.perform_async(project.id, true)
  end
end
