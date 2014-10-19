class ProjectDetails
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def project
    @project ||= Project.where(username: username, name: name).first
  end

  def exists?
    !project.blank?
  end

  def username
    @username ||= params[:username].freeze
  end

  def name
    @name ||= params[:name].freeze
  end

  def full_name
    # Don't delegate to project, because it might be nil
    "#{username}/#{name}"
  end

  def offenses
    @offenses ||= project.rubocop_offenses
      .includes(:source_file, :project)
      .order("""
    case rubocop_offenses.severity
      when 'convention' then 5
      when 'warning' then 4
      when 'refactor' then 3
      when 'error' then 2
      when 'fatal' then 1
      else 99
    end""")
      .page(params[:page]).per(10)
  end

  def total_offense_count
    @total_count    ||= all_offenses.count
  end

  def offense_count_per_severity
    @per_severity_count ||= all_offenses.group(:severity).count.sort_by{|_k,v| v}.reverse
  end

  def offense_count_per_cop_name
    @per_copname_count ||= all_offenses.group(:cop_name).count.sort_by{|_k,v| v}.reverse
  end

  def stars
    project.repository_data["stargazers_count"]
  end

  def forks
    project.repository_data["forks_count"]
  end

  def open_issues
    project.repository_data["open_issues_count"]
  end

  def subscribers
    project.repository_data["subscribers_count"]
  end

  def source_files_count
    project.source_files_count
  end

  private

  def all_offenses
    @all_offenses ||= RubocopOffense.includes(:source_file).where(source_files: { project_id: project.id })
  end
end
