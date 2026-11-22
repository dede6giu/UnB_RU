require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "sem login" do
      it "mostra a página inicial" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("<title>Página Inicial</title>")
      end

      it "tem a entrada do estudante, do operador e do admin" do
        get root_path
        expect(response.body).to include("href=\"#{new_student_session_path}\"")
        expect(response.body).to include("href=\"#{student_session_signup_path}\"")
        expect(response.body).to include("href=\"#{new_operator_session_path}\"")
        expect(response.body).to include("href=\"#{new_admin_session_path}\"")
      end

      it "mostra o cardápio da próxima refeição antes das entradas" do
        get root_path
        expect(response.body).to include('id="meal-widget"')
        expect(response.body).to include("href=\"#{public_menu_path}\"")
        expect(response.body.index("meal-widget")).to be < response.body.index("Entrar no sistema")
      end

      it "não mostra para o visitante os links das páginas do estudante" do
        get root_path
        expect(response.body).not_to include("href=\"#{student_portal_path}\"")
        expect(response.body).not_to include("href=\"#{new_recharge_path}\"")
        expect(response.body).not_to include("href=\"#{statement_path}\"")
      end
    end

    it "marca o Início no menu do topo, e o cardápio tem o caminho de volta" do
      get root_path
      expect(response.body).to include("aria-current=\"page\" href=\"#{root_path}\">Início</a>")

      get public_menu_path
      expect(response.body).to include("href=\"#{root_path}\">Início</a>")
      expect(response.body).to include("aria-current=\"page\" href=\"#{public_menu_path}\">Cardápio</a>")
    end

    context "estudante logado" do
      it "também vê a página inicial, com as entradas" do
        Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
        post student_session_path, params: { student: { user: "232012345", password: "senha123" } }

        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("href=\"#{new_student_session_path}\"")
      end
    end
  end

  describe "menu público" do
    it "não aparece nas páginas do estudante" do
      get new_student_session_path
      expect(response.body).not_to include('aria-label="Navegação principal"')

      Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
      post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
      get student_portal_path
      expect(response.body).not_to include('aria-label="Navegação principal"')
    end
  end

  describe "marca do cabeçalho" do
    it "leva para a página inicial, nos logins e no portal" do
      get new_student_session_path
      expect(response.body).to include("href=\"#{root_path}\"")

      get new_admin_session_path
      expect(response.body).to include("href=\"#{root_path}\"")

      Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
      post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
      get student_portal_path
      expect(response.body).to include("RU UnB Digital")
      expect(response.body).to include("href=\"#{root_path}\"")
    end
  end
end
