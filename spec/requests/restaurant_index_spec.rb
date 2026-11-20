require "rails_helper"

RSpec.describe "Restaurants", type: :request do
  let!(:conta) do
    Account.create!(user: "1234567", password: "senha123", name: "Admin", role: "admin")
  end

  def entrar
    post admin_session_path, params: { admin: { user: "1234567", password: "senha123" } }
  end

  describe "GET /admin/restaurants" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get restaurants_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants" do
        entrar
        get restaurants_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Gestão de Restaurantes e Catracas")
      end
    end
  end

  describe "GET /admin/turnstiles" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get turnstiles_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants" do
        entrar
        get turnstiles_path
        expect(response).to redirect_to(restaurants_path)
      end
    end
  end
end
