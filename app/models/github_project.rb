class GithubProject
  attr_reader :username, :name

  def initialize(username:, name:)
    @username, @name = username.freeze, name.freeze
  end

  def exists?
    return false if username.blank? || name.blank?
    !page_html.blank?
  end

  def contains_ruby?
    doc = Nokogiri::HTML(page_html)
    langs = doc.css('.repository-lang-stats-graph').first
    langs.content.downcase.include?("ruby")
  end

  # Convert to {Project} model
  # @return [Project,nil]
  def to_project
    return nil unless exists?
    doc = Nokogiri::HTML(page_html)
    Project.new(
      name: name,
      username: username,
      description: extract_description(doc),
    )
  end

  private

  def page_html
    @page_html ||= retrieve_page_html
  end

  def retrieve_page_html
    response = request_project_page
    return '' if response.status == 404

    response.body
  end

  def request_project_page
    conn = Faraday.new('https://github.com')
    conn.get("#{username}/#{name}")
  end

  def extract_description(node)
    desc_node = node.css('.repository-description').first
    return '' unless desc_node
    desc_node.content.strip
  end
end
