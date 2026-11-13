require "rails_helper"

RSpec.describe "StudentPortal", type: :request do
  describe "GET /student_portal" do
    it "mostra a página Portal do Estudante" do
      get student_portal_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Portal do Estudante")
    end

    it "tem links para a recarga e o extrato" do
      get student_portal_path
      expect(response.body).to include('href="/recharge/new"')
      expect(response.body).to include('href="/statement"')
    end
  end
end
