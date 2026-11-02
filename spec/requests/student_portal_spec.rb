require 'rails_helper'

RSpec.describe "StudentPortals", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/student_portal/new"
      expect(response).to have_http_status(:success)
    end
  end
end
