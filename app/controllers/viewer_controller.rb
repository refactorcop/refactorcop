class ViewerController < ApplicationController
  def show_project
    @project_details = ProjectDetails.new(params)
    if @project_details.exists?
      render layout: nil
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
    if gh.exists?
      gh.to_project.save!
      redirect_to({action: :show_project}, {
        username: @project_details.username,
        name: @project_details.name,
      })
    else
      redirect_to action: "project_not_found", :flash => {
        :error => "Could not find that project '#{@project_details.full_name}'"
      }
    end
  end
end
