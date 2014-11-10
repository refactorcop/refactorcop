class ViewerController < ApplicationController
  layout 'with_small_header'

  def show_project
    @project_details = ProjectDetails.new({
      username: params[:username],
      name:     params[:name],
      severity: params[:severity],
      page:     params[:page],
    })
    if @project_details.exists?
      render
    else
      attempt_project_import_and_redirect
    end
  end

  def random
    project = Project.where("rubocop_offenses_count > 0").order("RANDOM()").first
    redirect_to(action: "show_project", username: project.username, name: project.name)
  end

  def project_not_found
  end

  private

  def attempt_project_import_and_redirect
    gh = GithubProject.new(name: @project_details.name, username: @project_details.username)
    if !gh.exists?
      redirect_to action: "project_not_found", flash: { error: "Could not find that project '#{@project_details.full_name}'" }
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

    redirect_to({action: :show_project}, {
      username: project.username,
      name: project.name,
    })
  end
end
