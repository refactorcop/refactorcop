class AboutController < ApplicationController
  def welcome
    @dashboard = ProjectDashboard.new(params)
  end
end
