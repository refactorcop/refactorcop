puts "Importing trending Ruby projects from Github:"
projects = GithubTrending.new('ruby').persist_projects
projects.each do |project|
  puts "* Linting #{project.full_name.inspect}"
  RubocopWorker.new.perform(project.id)
end
puts "Done."
