require 'rails_helper'

RSpec.describe ProjectsController, :type => :controller do

  describe "GET send_cops" do
    it "triggers a RubocopWorker" do
      project = create(:project)
      expect(RubocopWorker).to receive(:perform_async).with(project.id)
      get :send_cops, id: project.id
      expect(response).to redirect_to(action: 'show', name: project.name, username: project.username)
    end
  end

end
