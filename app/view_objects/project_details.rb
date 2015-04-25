class ProjectDetails
  attr_reader :username, :name, :severity, :page

  def initialize(username:, name:, page: 1, severity: nil)
    @username ||= username.freeze
    @name     ||= name.gsub(/\?.*/, '').freeze
    @severity ||= severity.freeze
    @page     ||= page.freeze
  end

  def project
    @project ||= Project.find_by_full_name(username, name)
  end

  def exists?
    !project.blank?
  end

  def has_todo?
    @project.has_todo?
  end

  def full_name
    # Don't delegate to project, because it might be nil
    "#{username}/#{name}"
  end

  def offenses
    @offenses ||= filter_by_severity(all_offenses)
      .order_by_severity
      .page(page).per(10)
  end

  def total_offense_count
    @total_count ||= all_offenses.count
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

  def cache_key
    suffix =
      if project.rubocop_last_run_at
        project.rubocop_last_run_at.strftime('%Y-%m-%d')
      else
        'unlinted'
      end
    [project.full_name, suffix].join('__')
  end

  private

  def all_offenses
    @all_offenses ||= project.rubocop_offenses.includes(:source_file, :project)
  end

  def filter_by_severity(offenses)
    if severity.blank?
      offenses
    else
      offenses.where(severity: severity)
    end
  end
end
