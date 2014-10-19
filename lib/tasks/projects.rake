namespace :projects do
  desc "Import from GitHub"
  task :import => :environment do
    GithubTrending.new('ruby').persist_projects
  end

  desc "Download code and lint"
  task :lint => :environment do
    project = Project.all.sample
    puts "Linting project: #{project.id} - #{project.full_name}"
    project.update_source_files!
    puts "Following files will be linted:"
    project.reload
    project.source_files.each do |sf|
      puts "* #{sf.path}"
    end
  end

  desc "Force a run for all projects"
  task :queue_all => :environment do
    Project.all.each do |project|
      puts "Queuing project: #{project.id} - #{project.full_name}"
      RubocopWorker.perform_async(project.id, true)
    end
  end

  desc "Force a run for a given project ID"
  task :queue, [:project_id] => [:environment] do |p, args|
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
