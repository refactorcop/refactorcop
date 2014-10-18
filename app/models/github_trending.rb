class GithubTrending
  attr_reader :language

  def initialize(language = 'ruby')
    @language = language.freeze
  end

  def repositories
    doc = Nokogiri::HTML(trending_page_html)
    doc.css('.repo-list-item').map do |list_item|
      Project.new(list_item)
    end
  end

  private

  def trending_page_html
    return @trending_page_html if @trending_page_html
    conn = Faraday.new('https://github.com')
    response = conn.get('trending', l: language)
    @trending_page_html = response.body
  end

  class Project
    attr_reader :username, :name, :description

    def initialize(list_item)
      name_parts = list_item.css('.repo-list-name').first.content.strip.split(' ')
      @name = name_parts.last.strip
      @username = name_parts.first.strip
      @description = list_item.css('.repo-list-description').first.content.strip
    end

    def github_path
      "/#{username}/#{name}"
    end

    def clone_url
      "git@github.com:#{username}/#{name}.git"
    end
  end
end
