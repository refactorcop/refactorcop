class ViewerController < ApplicationController

  before_action :project_exists?

  def project_exists?
    @username = params[ "username" ]
    @name = params[ "name" ]

    if !Project.exists?( { username: @username, name: @name } )
      redirect_to '/about/welcome', :flash => { :error => "We have not indexed this repository yet, sorry!" }
    end

    @project = Project.where( { username: @username, name: @name } ).first

  end
  
  def showproject

    # dashboards

    @total_count = RubocopOffense.includes( :source_file ).where( source_files: { project_id: @project } ).count
    @severity_count = RubocopOffense.includes( :source_file ).where( source_files: { project_id: @project } ).group( :severity ).count.sort_by{|k,v| v}.reverse
    @copname_count = RubocopOffense.includes( :source_file ).where( source_files: { project_id: @project } ).group( :cop_name ).count.sort_by{|k,v| v}.reverse
    
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
end
