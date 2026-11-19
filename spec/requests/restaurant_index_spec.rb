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

  describe "tema" do
    it "as páginas do admin usam o tema claro, mesmo com o navegador no modo escuro" do
      post admin_session_path, params: { admin: { user: "1234567", password: "senha123" } }
      get restaurants_path
      expect(response.body).to include('<body data-bs-theme="light"')
    end
  end

  describe "GET /admin/turnstiles" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get turnstiles_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end
