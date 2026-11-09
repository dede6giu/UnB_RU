require 'rails_helper'

RSpec.describe "AccessControls", type: :request do
  describe "GET /check" do
    it "returns http success" do
      get "/access_control/check"
      expect(response).to have_http_status(:success)
    end
  end

end
