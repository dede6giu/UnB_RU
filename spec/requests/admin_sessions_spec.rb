require "rails_helper"

RSpec.describe "AdminSessions", type: :request do
  let!(:admin) do
    Account.create!(user: "1000000", password: "senha123", name: "Admin", role: "admin")
  end

  def entrar(user:, password:)
    post admin_sessions_path, params: { admin: { user: user, password: password } }
  end

  describe "GET /admin_sessions/new" do
    it "mostra a página de login" do
      get admin_sessions_new_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Autenticação de Admin")
    end
  end

  describe "POST /admin_sessions" do
    it "autentica com matrícula e senha certas" do
      entrar(user: "1000000", password: "senha123")
      expect(response).to redirect_to(admin_sessions_new_path)
      expect(flash[:notice]).to eq("Sucesso na autenticação.")
      expect(session[:admin_id]).to eq(admin.id)
    end

    it "recusa matrícula com formato inválido" do
      entrar(user: "123", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula inválida.")
      expect(session[:admin_id]).to be_nil
    end

    it "recusa senha errada" do
      entrar(user: "1000000", password: "errada99")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
      expect(session[:admin_id]).to be_nil
    end

    it "recusa matrícula que não existe" do
      entrar(user: "7654321", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
    end

    it "recusa a conta de um operador" do
      Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      entrar(user: "2000000", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
      expect(session[:admin_id]).to be_nil
    end
  end
end
