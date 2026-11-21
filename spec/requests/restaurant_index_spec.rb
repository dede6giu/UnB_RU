require "rails_helper"

RSpec.describe "Restaurants", type: :request do
  let!(:conta) do
    Account.create!(user: "1234567", password: "senha123", name: "Meu nome é admin.", role: "admin")
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

      it "usa o tema claro, mesmo com o navegador no modo escuro" do
        get restaurants_path
        expect(response.body).to include('<body data-bs-theme="light"')
      end

      it "tem botão para cadastro de restaurant" do
        get restaurants_path
        expect(response.body).to include("action=\"#{new_restaurant_path}\"")
      end

      it "tem botão para cadastro de turnstile" do
        get restaurants_path
        expect(response.body).to include("action=\"#{new_turnstile_path}\"")
      end

      it "tem link para Gestão de Restaurantes" do
        get restaurants_path
        expect(response.body).to include("href=\"#{restaurants_path}\"")
      end

      it "tem link para Index" do
        get restaurants_path
        expect(response.body).to include("href=\"/\"")
      end

      it "mostra o nome do admin" do
        get restaurants_path
        expect(response.body).to include(conta.name)
      end

      it "mostra a matrícula do admin" do
        get restaurants_path
        expect(response.body).to include(conta.user)
      end

      it "tem botão para logout" do
        get restaurants_path
        expect(response.body).to include(/<form(?:.*)method="post" action="#{Regexp.escape(admin_session_path)}"><input(?:.*)value="delete"(?:.*)<\/form>/)
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
