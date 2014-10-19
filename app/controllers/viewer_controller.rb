class ViewerController < ApplicationController
  def showproject
    @project_details = ProjectDetails.new(params)
    unless @project_details.exists?
      redirect_to '/about/welcome', :flash => {
        :error => "We have not indexed this repository yet, sorry!"
      }
    end
  end

  def random
    project = Project.order("RANDOM()").first
    redirect_to(action: "showproject", username: project.username, name: project.name)
  end
end
