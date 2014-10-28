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
#  rubocop_run_started_at :datetime
#  rubocop_last_run_at    :datetime
#

class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false
  validates_uniqueness_of :name, scope: :username

  has_many :source_files, dependent: :destroy
  has_many :rubocop_offenses, through: :source_files

  scope :linted, lambda {
    #where("rubocop_last_run_at IS NOT NUL AND rubocop_last_run_at > rubocop_run_started_at")
    t = self.arel_table
    where(t[:rubocop_last_run_at].not_eq(nil).and(t[:rubocop_last_run_at].gt(t[:rubocop_run_started_at])))
  }

  # Has this project been linted before?
  def linted?
    rubocop_last_run_at.present?
  end

  # Checks whether we are currently running rubocop on this project
  def rubocop_running?
    (rubocop_last_run_at.nil? && rubocop_run_started_at.present?) ||
    (rubocop_run_started_at.present? && rubocop_last_run_at.present? &&
      rubocop_run_started_at > rubocop_last_run_at)
  end

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

  def severity_counts
    RubocopOffense.includes(:source_file)
      .where(source_files: { project_id: id })
      .group(:severity)
      .count
      .with_indifferent_access
  end

  def last_index_run_time
    return nil if rubocop_run_started_at.blank? || rubocop_last_run_at.blank?
    return nil if rubocop_running?
    (rubocop_last_run_at - rubocop_run_started_at).to_i
  end

  private

  def github_api
    @github_api ||=
      if Rails.env.production?
        Github.new(basic_auth: "#{ENVied.GITHUB_EMAIL}:#{ENVied.GITHUB_PASSWORD}")
      else
        Github.new
      end
  end

  class << self
    def find_by_full_name(username, name)
      t = arel_table
      sql = t[:username].lower.eq(username.downcase).and(t[:name].lower.eq(name.downcase))
      where(sql).first
    end
  end
end
