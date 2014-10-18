require 'rails_helper'

RSpec.describe ViewerController, :type => :controller do

  describe "GET showproject" do
    it "returns http success" do
      get :showproject
      expect(response).to have_http_status(:success)
    end
  end

end
