class ViewerController < ApplicationController
  def showproject
    @username = params[ "username" ]
    @name = params[ "name" ]
  end
end
