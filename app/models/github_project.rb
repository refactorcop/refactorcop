class GithubProject
  attr_reader :username, :name

  def initialize(username:, name:)
    @username, @name = username.freeze, name.freeze
  end

  def exists?
    return false if username.blank? || name.blank?
    !page_html.blank?
  end

  # Convert to {Project} model
  # @return [Project,nil]
  def to_project
    return nil unless exists?
    doc = Nokogiri::HTML(page_html)
    Project.new({
      name: name,
      username: username,
      description: doc.css('.repository-description').first.content.strip,
    })
  end

  private

  def page_html
    return @page_html if @page_html
    conn = Faraday.new('https://github.com')
    response = conn.get("#{username}/#{name}")
    if response.status == 404
      @page_html = ''
    else
      @page_html = response.body
    end
  end

  def project_form_node(node)
    name_parts = node.css('.repo-list-name').first.content.strip.split(' ')
    Project.where({
      name: name_parts.last.strip,
      username: name_parts.first.strip,
    }).first_or_initialize({
      description: node.css('.repo-list-description').first.content.strip,
    })
  end
end
