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
    Project.new({
      name: name,
      username: username,
      description: doc.css('.repository-description').first.content.strip,
    })
  end

  private

  def page_html
    return @page_html if @page_html
    response = request_project_page
    if response.status == 404
      @page_html = ''
    else
      @page_html = response.body
    end
  end

  def request_project_page
    conn = Faraday.new('https://github.com')
    conn.get("#{username}/#{name}")
  end
end
