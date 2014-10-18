# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  username    :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false
  validates_uniqueness_of :name, scope: :username

  def clone_url
    "git@github.com:#{username}/#{name}.git"
  end
end

  def download_zip_url(branch: 'master')
    "https://github.com/#{username}/#{name}/archive/#{branch}.zip"
  end

  def fetch_github_repository_data
    github = Github.new
    response = github.repos.get username, name
    self.repository_data = response.to_hash.to_json
    save!
  end

  def default_branch
    #json = curl "https://api.github.com/repos/#{username}/#{name}"
    fetch_github_repository_data if repository_data.blank?

    repository_data['default_branch']
  end

  def project_updated?
    fetch_github_repository_data
    last_ != repository_data[:pushed_at]
  end
