class ProjectDashboard
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def trending
    Project.all.limit(5)
  end

  def recommended
    Project.all.limit(5).order('random()')
  end

  def search_results
    Project
      .where("name ILIKE ? or description ILIKE ?", "%#{query}%",  "%#{query}%")
      .limit(25)
  end

  def search?
    !query.blank?
  end

  def query
    params[:query].freeze
  end
end
