class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_github_auth(auth_hash)
    session[:user_id] = @user.id
    redirect_to projects_path
  end

  def failure
    redirect_to root_path, notice: 'We failed to authenticate with your Github account'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
