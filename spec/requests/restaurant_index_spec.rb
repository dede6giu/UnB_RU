require "rails_helper"

RSpec.describe "Restaurants", type: :request do
  let!(:conta) do
    Account.create!(user: "1234567", password: "senha123", name: "Admin", role: "admin")
  end

  def entrar
    post admin_session_path, params: { student: { user: "1234567", password: "senha123" } }
  end

  describe "GET /admin/restaurants" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get restaurants_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end
