class AboutController < ApplicationController
  def welcome
    # pick a lucky winner for the i'm feeling lucky button
    @random_project = Project.limit(1).offset(rand(Project.count)).first
    if params[ "query" ]
      @query = params[ "query" ]
      @projects = Project.where( "name ILIKE ? or description ILIKE ?", "%#{@query}%",  "%#{@query}%" )
    else
      @query = nil
      @projects = Project.all
    end
  end
end
