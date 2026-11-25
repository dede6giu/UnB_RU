require "rails_helper"

RSpec.describe "StudentSessions", type: :request do
  let!(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end

  def entrar(user:, password:)
    post student_session_path, params: { student: { user: user, password: password } }
  end

  describe "GET /student_session/new" do
    it "mostra a página de login" do
      get new_student_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Autenticação do Estudante")
    end
  end

  describe "POST /student_session" do
    it "autentica e vai para o Portal do Estudante" do
      entrar(user: "232012345", password: "senha123")
      expect(response).to redirect_to(student_portal_path)
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

  describe "links entre o login e o cadastro" do
    it "o login leva para o cadastro e o cadastro leva para o login" do
      get new_student_session_path
      expect(response.body).to include("href=\"#{student_session_signup_path}\"")

      get student_session_signup_path
      expect(response.body).to include("href=\"#{new_student_session_path}\"")
    end
  end

  describe "POST /student/newacc com campos vazios" do
    it "mostra cada erro numa linha, em vermelho, sem criar a conta" do
      expect do
        post student_session_newacc_path, params: { student_user: "", student_name: "", student_password: "" }
      end.not_to change(Account, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).not_to include("{user:")
      expect(response.body).to include('<div class="alert theme-danger mb-4">Matrícula não pode ser vazia.</div>')
      expect(response.body).to include('<div class="alert theme-danger mb-4">Senha não pode ser vazia.</div>')
      expect(response.body).not_to include("theme-success")
    end
  end

    describe "DELETE /student/login" do
    it "sai da conta e volta para o login" do
      entrar(user: "232012345", password: "senha123")
      get student_portal_path
      expect(response.body).to include('<input type="hidden" name="_method" value="delete"')

      delete student_session_path
      expect(response).to redirect_to(new_student_session_path)
      expect(session[:student_id]).to be_nil

      get student_portal_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end

  describe "já logado"do
    before { entrar(user: "232012345", password: "senha123") }
    it "não permite entrar de novo e redireciona para o portal" do
      get new_student_session_path
      expect(response).to redirect_to(student_portal_path)
    end
    it "não mostra o cadastro e redireciona para o portal" do
      get student_session_signup_path
      expect(response).to redirect_to(student_portal_path)
    end
  end
end
