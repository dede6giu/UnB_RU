require 'rails_helper'

RSpec.describe "AdminSessions", type: :request do
  describe "GET /admin_sessions" do
    it "works! (now write some real specs)" do
      get admin_sessions_new_path
      expect(response).to have_http_status(200)
    end
  end
end
