class ViewerController < ApplicationController
  before_action :project_exists?, only: [:showproject]

  def project_exists?
    @username = params["username"]
    @name = params["name"]

    @project = Project.where(username: @username, name: @name).first
    unless @project
      redirect_to '/about/welcome', :flash => { :error => "We have not indexed this repository yet, sorry!" }
    end
  end

  def showproject
    # dashboards
    all_offenses = RubocopOffense.includes(:source_file).where(source_files: { project_id: @project })
    @total_count    = all_offenses.count
    @severity_count = all_offenses.group(:severity).count.sort_by{|k,v| v}.reverse
    @copname_count  = all_offenses.group(:cop_name).count.sort_by{|k,v| v}.reverse

    # paginated view

    @offenses = @project.rubocop_offenses.order(
    "case rubocop_offenses.severity
      when 'convention' then 5
      when 'warning' then 4
      when 'refactor' then 3
      when 'error' then 2
      when 'fatal' then 1
      else 99
    end").includes(:source_file, :project)

    @offenses = @offenses.page(params[:page]).per(10)
  end

  def random
    project = Project.order("RANDOM()").first
    redirect_to(action: "showproject", username: project.username, name: project.name)
  end
end
