class AboutController < ApplicationController
  def welcome
    # pick a lucky winner for the i'm feeling lucky button
    @random_project = Project.limit(1).offset(rand(Project.count)).first
  end
end
