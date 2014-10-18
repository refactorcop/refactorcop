# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  username               :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  repository_data        :json
#  source_files_count     :integer          default(0), not null
#  rubocop_offenses_count :integer          default(0), not null
#

class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false
  validates_uniqueness_of :name, scope: :username

  has_many :source_files
  has_many :rubocop_offenses, through: :source_files

  def clone_url
    "git@github.com:#{username}/#{name}.git"
  end

  def full_name
    "#{username}/#{name}"
  end

  def download_zip_url
    branch = default_branch || "master"
    "https://github.com/#{username}/#{name}/archive/#{branch}.zip"
  end

  def fetch_github_repository_data
    github_api.repos.get(username, name).to_h.with_indifferent_access
  end

  def update_repository_data(fetched_repository_data = nil )
    self.repository_data = fetched_repository_data || fetch_github_repository_data
    Rails.logger.info "updating repository_data"
    save! #unless repository_data.nil?
  end

  def repository_data
    super || self.repository_data = fetch_github_repository_data
  end

  def default_branch
    return nil if repository_data.blank?

    repository_data["default_branch"]
  end

  def pushed_at
    if repository_data.blank? || repository_data["pushed_at"].blank?
      return 100.years.ago
    end
    DateTime.parse(repository_data["pushed_at"])
  end

  def new_commits?
    github = fetch_github_repository_data
    pushed_at != github[:pushed_at]
  end

  # Imports the projects code from GitHub. Stores code in {SourceFile#content}.
  # @return [undefined]
  def update_source_files!
    github_repository_data = fetch_github_repository_data
    Project::Download.call(self)

    update_repository_data github_repository_data
  end

  private

  def github_api
    @github_api ||= Github.new
  end

end
