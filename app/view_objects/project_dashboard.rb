class ProjectDashboard
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def trending
    @trending ||= linted_projects.not_private.limit(5).order('rubocop_offenses_count DESC')
  end

  def recommended
    @recommended ||= linted_projects.not_private
      .where('rubocop_offenses_count > 0')
      .limit(5).order('random()')
  end

  private

  def linted_projects
    Project.linted
  end
end
