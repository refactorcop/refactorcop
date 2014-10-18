class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false

  def clone_url
    "git@github.com:#{username}/#{name}.git"
  end
end
