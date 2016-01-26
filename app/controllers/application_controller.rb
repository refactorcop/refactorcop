class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_admin
    authenticate_or_request_with_http_basic("Recovering Vegetarian Area") do |username, password|
      AdminAuthentication.call(username, password)
    end
  end
end
