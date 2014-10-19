class ViewerController < ApplicationController
  def showproject
    @project_details = ProjectDetails.new(params)
    unless @project_details.exists?
      attempt_project_import_and_redirect
    end
  end

  def random
    project = Project.order("RANDOM()").first
    redirect_to(action: "showproject", username: project.username, name: project.name)
  end

  private

  def attempt_project_import_and_redirect
    gh = GithubProject.new(name: @project_details.name, username: @project_details.username)
    if gh.exists?
      gh.to_project.save!
      redirect_to '/about/welcome', :flash => {
        :error => "We have not indexed this repository yet, sorry!"
      }
    else
      redirect_to '/about/welcome', :flash => {
        :error => "Could not find that project '#{@project_details.full_name}'"
      }
    end
  end
end
