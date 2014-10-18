class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false

  def github_path
    "/#{username}/#{name}"
  end

  def clone_url
    "git@github.com:#{username}/#{name}.git"
  end
end
