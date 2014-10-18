class GithubTrending
  attr_reader :language

  def initialize(language = 'ruby')
    @language = language.freeze
  end

  def repositories
    doc = Nokogiri::HTML(trending_page_html)
    doc.css('.repo-list-item').map do |list_item|
      project_form_node(list_item)
    end
  end

  private

  def trending_page_html
    return @trending_page_html if @trending_page_html
    conn = Faraday.new('https://github.com')
    response = conn.get('trending', l: language)
    @trending_page_html = response.body
  end

  def project_form_node(node)
    name_parts = node.css('.repo-list-name').first.content.strip.split(' ')
    Project.new({
      name: name_parts.last.strip,
      username: name_parts.first.strip,
      description: node.css('.repo-list-description').first.content.strip,
    })
  end
end
