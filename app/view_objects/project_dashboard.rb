class ProjectDashboard
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def trending
    @trending ||= linted_projects.limit(5).order('rubocop_offenses_count DESC')
  end

  def recommended
    @recommended ||= linted_projects
      .where('rubocop_offenses_count > 0')
      .limit(5).order('random()')
  end

  def search_results
    @search_results ||= Project
      .where("name ILIKE ? or description ILIKE ?", "%#{query}%", "%#{query}%")
      .page(params[:page]).per(20)
  end

  def search?
    !query.blank?
  end

  def query
    @query ||= params[:query].freeze
  end

  private

  def linted_projects
    Project.linted
  end
end
