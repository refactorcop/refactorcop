class ViewerController < ApplicationController
  
  before_action :project_exists?
  
  def project_exists?
    @username = params[ "username" ]
    @name = params[ "name" ]
    
    if !Project.exists?( { username: @username, name: @name } )
      redirect_to '/about/welcome', :flash => { :error => "We have not indexed this repository yet, sorry!" }
    end
  end
  
  def showproject
  end
end
