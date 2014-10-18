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
end
