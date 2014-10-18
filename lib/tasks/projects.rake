namespace :projects do
  desc "Import from GitHub"
  task :import => :environment do
    GithubTrending.new('ruby').persist_projects
  end
end
