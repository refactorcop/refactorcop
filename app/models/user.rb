class User < ActiveRecord::Base
  has_many :projects, foreign_key: 'owner_id'

  validates_presence_of :email, :github_uid, :github_token

  def self.find_or_create_from_github_auth(auth_hash)
    find_or_create_by(github_uid: auth_hash[:uid]) do |u|
      u.github_token = auth_hash[:credentials][:token]
      u.email = auth_hash[:info][:email]
    end
  end

  def projects_count
    projects.size
  end

  def github_client
    @github_client ||= Github.new oauth_token: github_token
  end
end
