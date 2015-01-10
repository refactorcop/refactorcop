class ProjectsController < ApplicationController
  layout 'with_small_header'

  before_filter :authorize, only: [:index]

  def index
    @projects = current_user.projects
  end

  def search
    @query = params[:query]
    @search_results ||= Project.not_private
      .where("name ILIKE :query or description ILIKE :query", query: "%#{@query}%")
      .page(params[:page]).per(20)
  end

  def import
    redirect_to find_project(params[:username], params[:name])
  end

  def show
    @project_details = ProjectDetails.new({
      username: params.fetch(:username, ''),
      name:     params.fetch(:name, ''),
      severity: params[:severity],
      page:     params[:page],
      current_user: current_user
    })

    if @project_details.exists?
      render
    else
      attempt_project_import_and_redirect
    end
  end

  def send_cops
    project = Project.find_by_id!(params[:id])
    if project.rubocop_running?
      redirect_to_project(project, flash: { notice: "Cops already sent!" })
    else
      RubocopWorker.perform_async(project.id)
      redirect_to_project(project, flash: {
        notice: "Cops sent! The results should be here within a couple of minutes."
      })
    end
  end

  def random
    project = Project.not_private.where("rubocop_offenses_count > 0").order("RANDOM()").first
    if project.nil?
      redirect_to project_not_found_path
    else
      redirect_to_project(project)
    end
  end

  def not_found
    render status: :not_found
  end

  private

  def redirect_to_project(project, extra_opts = {})
    opts = extra_opts.merge({
      action: "show",
      username: project.username,
      name: project.name
    })
    flashes = opts.delete(:flash)
    redirect_to(opts, {flash: flashes})
  end

  def attempt_project_import_and_redirect
    gh = GithubProject.new(name: @project_details.name, username: @project_details.username, current_user: current_user)
    if !gh.exists?
      redirect_to action: "not_found", flash: { error: "Could not find that project '#{@project_details.full_name}'" }
      return
    end
    if !gh.contains_ruby?
      redirect_to root_path, flash: { error: "This project does not seem to contain a significant amount of ruby code." }
      return
    end
    save_and_redirect_to_project gh.to_project
  end

  def save_and_redirect_to_project(project)
    project.save!
    RubocopWorker.perform_async(project.id)
    redirect_to_project(project)
  end
end
