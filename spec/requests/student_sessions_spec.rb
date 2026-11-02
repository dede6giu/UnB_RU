require "rails_helper"

RSpec.describe "StudentSessions", type: :request do
  let!(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end

  def entrar(user:, password:)
    post student_sessions_path, params: { student: { user: user, password: password } }
  end

  describe "GET /student_sessions/new" do
    it "mostra a página de login" do
      get student_sessions_new_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Autenticação do Estudante")
    end
  end

  describe "POST /student_sessions" do
    it "autentica e vai para o Portal do Estudante" do
      entrar(user: "232012345", password: "senha123")
      expect(response).to redirect_to(student_portal_new_path)
      expect(flash[:notice]).to eq("Sucesso na autenticação.")
      expect(session[:student_id]).to eq(estudante.id)
    end

    it "recusa matrícula fora do formato AA SS DDDDD" do
      entrar(user: "233012345", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula inválida.")
      expect(session[:student_id]).to be_nil
    end

    it "recusa senha errada" do
      entrar(user: "232012345", password: "errada99")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
      expect(session[:student_id]).to be_nil
    end

    it "recusa matrícula que não existe" do
      entrar(user: "232054321", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha incorretas.")
    end

    it "recusa a conta de um operador" do
      Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      entrar(user: "2000000", password: "senha123")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:student_id]).to be_nil
    end
  end
end
