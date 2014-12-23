class GithubTrending
  attr_reader :language

  def initialize(language = 'ruby')
    @language = language.freeze
  end

  # Projects on the github trending page
  # @return [Array<Project>]
  def projects
    doc = Nokogiri::HTML(trending_page_html)
    doc.css('.repo-list-item').map do |list_item|
      project_from_node(list_item)
    end
  end

  # Updates or creates {Project}s in database
  # @return [undefined]
  def persist_projects
    projects.each(&:save!)
  end

  private

  def trending_page_html
    @response ||= Faraday.new('https://github.com')
      .get('trending', l: language)
      .body
  end

  def project_from_node(node)
    name_parts = node.css('.repo-list-name').first.content.strip.split(' ')
    Project.where({
      name: name_parts.last.strip,
      username: name_parts.first.strip,
    }).first_or_initialize(description: extract_description(node))
  end

  def extract_description(node)
    desc_node = node.css('.repo-list-description').first
    return '' unless desc_node
    desc_node.content.strip
  end
end
