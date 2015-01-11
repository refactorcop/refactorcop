class GithubProject
  attr_reader :username, :name, :current_user

  def initialize(username:, name:, current_user: nil)
    @username, @name = username.freeze, name.freeze
    @current_user = current_user
  end

  def exists?
    return false if username.blank? || name.blank?
    project_repository.present?
  end

  def contains_ruby?
    github_api.repos.languages(username, name).has_key? 'Ruby'
  end

  # Convert to {Project} model
  # @return [Project,nil]
  def to_project
    return nil unless exists?
    owner = private_repository? ? current_user : nil
    Project.new({
      name: name,
      username: username,
      description: description,
      private_repository: private_repository?,
      owner: owner
    })
  end

  private

  def project_repository
    @project_respository ||= github_api.repos.get(username, name)
  rescue Github::Error::NotFound
    nil
  end

  def description
    project_repository.description || ''
  end

  def private_repository?
    project_repository.private
  end

  def github_api
    @github_api ||=
      if current_user
        current_user.github_client
      else
        if Rails.env.production?
          Github.new(basic_auth: "#{ENVied.GITHUB_EMAIL}:#{ENVied.GITHUB_PASSWORD}")
        else
          Github.new
        end
      end
  end
end
