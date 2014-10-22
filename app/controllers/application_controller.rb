class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_screenshot

  def authenticate_admin
    authenticate_or_request_with_http_basic("Recovering Vegetarian Area") do |name, password|
      name == "admin" && password == ENV["ADMIN_PASSWORD"]
    end
  end

  protected

  def check_screenshot
    unless params[:screenshot].blank?
      redirect_to "/screenshot.html"
    end
  end
end
