class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_screenshot

  def authenticate_admin
    authenticate_or_request_with_http_basic("Recovering Vegetarian Area") do |username, password|
      AdminAuthentication.call(username, password)
    end
  end

  protected

  def check_screenshot
    unless params[:screenshot].blank?
      redirect_to "/screenshot.html"
    end
  end

  def authorize
    redirect_to root_url, alert: 'Not logged in' if current_user.nil?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
