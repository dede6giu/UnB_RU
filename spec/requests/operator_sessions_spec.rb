require "rails_helper"

RSpec.describe "OperatorSessions", type: :request do
  let!(:operador) do
    Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
  end

  def entrar(user:, password:)
    post operator_sessions_path, params: { operator: { user: user, password: password } }
  end

  describe "GET /operator_sessions/new" do
    it "mostra a página de login" do
      get operator_sessions_new_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Autenticação do Operador")
    end
  end

  describe "POST /operator_sessions" do
    it "autentica e vai para a Configuração de Ponto" do
      entrar(user: "2000000", password: "senha123")
      expect(response).to redirect_to(access_points_new_path)
      expect(flash[:notice]).to eq("Sucesso na autenticação.")
      expect(session[:operator_id]).to eq(operador.id)
    end

    it "recusa matrícula com formato inválido" do
      entrar(user: "232012345", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula inválida.")
      expect(session[:operator_id]).to be_nil
    end

    it "recusa senha errada" do
      entrar(user: "2000000", password: "errada99")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
      expect(session[:operator_id]).to be_nil
    end

    it "recusa matrícula que não existe" do
      entrar(user: "7654321", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
    end

    it "recusa a conta de um admin" do
      Account.create!(user: "1000000", password: "senha123", name: "Admin", role: "admin")
      entrar(user: "1000000", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
      expect(session[:operator_id]).to be_nil
    end
  end
end
