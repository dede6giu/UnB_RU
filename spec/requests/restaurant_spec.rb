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

      it "mostra a página de restaurants" do
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

  describe "GET /admin/restaurants/new" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get new_restaurant_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "mostra a página de criação de restaurants" do
        get new_restaurant_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Nova Unidade")
      end
    end
  end

  describe "GET /admin/restaurants/:id/edit" do
    let!(:restaurant) do
      Restaurant.create!(name: "RU 1", campus: "Planaltina")
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        get edit_restaurant_path(restaurant)
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "mostra a página de edição de restaurants" do
        get edit_restaurant_path(restaurant)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Editar Unidade")
      end
    end
  end

  describe "GET /admin/restaurants/:id" do
    let!(:restaurant) do
      Restaurant.create!(name: "RU 1", campus: "Planaltina")
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        get restaurant_path(restaurant)
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants" do
        get restaurant_path(restaurant)
        expect(response).to redirect_to(restaurants_path)
      end
    end
  end

  describe "POST /admin/restaurants/:id" do
    def criar_restaurant(name:, campus:)
      post restaurants_path, params: { restaurant: { name: name, campus: campus }  }
    end

    context "sem login" do
      it "redireciona para o login de admin e não cria o restaurant" do
        criar_restaurant(name: "RU 1", campus: "Planaltina")
        expect(response).to redirect_to(new_admin_session_path)
        expect(Restaurant.count).to eq(0)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e cria o restaurant" do
        criar_restaurant(name: "RU 1", campus: "Planaltina")
        expect(response).to redirect_to(restaurants_path)
        expect(Restaurant.count).to eq(1)
      end

      it "rejeita nome vazio" do
        criar_restaurant(name: "", campus: "Planaltina")
        expect(response).to have_http_status(:unprocessable_content)
        expect(Restaurant.count).to eq(0)
      end

      it "rejeita campus vazio" do
        criar_restaurant(name: "RU 1", campus: "")
        expect(response).to have_http_status(:unprocessable_content)
        expect(Restaurant.count).to eq(0)
      end

      it "rejeita restaurante existente" do
        criar_restaurant(name: "RU 1", campus: "Planaltina")
        expect(Restaurant.count).to eq(1)
        criar_restaurant(name: "RU 1", campus: "Planaltina")
        expect(response).to have_http_status(:unprocessable_content)
        expect(Restaurant.count).to eq(1)
      end
    end
  end

  describe "DELETE /admin/restaurants/:id" do
    let!(:restaurant) do
      Restaurant.create!(name: "RU 1", campus: "Planaltina")
    end
    def destruir
      delete restaurant_path(restaurant)
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        destruir
        expect(response).to redirect_to(new_admin_session_path)
        expect(Restaurant.count).to eq(1)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e destrói o restaurant" do
        destruir
        expect(response).to redirect_to(restaurants_path)
        expect(Restaurant.count).to eq(0)
      end

      it "não destrói se o restaurant tem uma turnstile operando" do
        Account.create!(user: "1000000", name: "operador", role: "operator", password: "operator")
        Turnstile.create!(name: "c1", operation: "Operando", restaurant_id: restaurant.id, operator_id: "1000000")
        destruir
        expect(response).to have_http_status(:unprocessable_content)
        expect(Restaurant.count).to eq(1)
      end
    end
  end

  describe "PATCH/PUT /admin/restaurants/:id" do
    let!(:restaurant) do
      Restaurant.create!(name: "RU 1", campus: "Planaltina")
    end
    let!(:diner) do
      Restaurant.create!(name: "Amarelinho", campus: "Darcy Ribeiro")
    end
    def atualizar(name:, campus:)
      patch restaurant_path(restaurant), params: { restaurant: { name: name, campus: campus } }
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        atualizar(name: "RU 4", campus: "Darcy Ribeiro")
        expect(response).to redirect_to(new_admin_session_path)
        restaurant.reload
        expect(restaurant.name).to eq("RU 1")
        expect(restaurant.campus).to eq("Planaltina")
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e atualiza o restaurant" do
        atualizar(name: "RU 4", campus: "Darcy Ribeiro")
        expect(response).to redirect_to(restaurants_path)
        restaurant.reload
        expect(restaurant.name).to eq("RU 4")
        expect(restaurant.campus).to eq("Darcy Ribeiro")
      end

      it "não aceita nome vazio" do
        atualizar(name: "", campus: "Planaltina")
        expect(response).to have_http_status(:unprocessable_content)
        restaurant.reload
        expect(restaurant.name).to eq("RU 1")
        expect(restaurant.campus).to eq("Planaltina")
      end

      it "não aceita campus vazio" do
        atualizar(name: "RU 1", campus: "")
        expect(response).to have_http_status(:unprocessable_content)
        restaurant.reload
        expect(restaurant.name).to eq("RU 1")
        expect(restaurant.campus).to eq("Planaltina")
      end

      it "não aceita restaurant existente" do
        atualizar(name: diner.name, campus: diner.campus)
        expect(response).to have_http_status(:unprocessable_content)
        restaurant.reload
        expect(restaurant.name).to eq("RU 1")
        expect(restaurant.campus).to eq("Planaltina")
      end
    end
  end

  # describe "GET /admin/turnstiles" do
  #   context "sem login" do
  #     it "redireciona para o login de admin" do
  #       get turnstiles_path
  #       expect(response).to redirect_to(new_admin_session_path)
  #     end
  #   end
  #
  #   context "com login" do
  #     before { entrar }
  #
  #     it "redireciona para a página de restaurants" do
  #       get turnstiles_path
  #       expect(response).to redirect_to(restaurants_path)
  #     end
  #   end
  # end

  describe "sem login e com id que não existe" do
    it "manda para o login do admin antes de procurar o registro" do
      get restaurant_path(999)
      expect(response).to redirect_to(new_admin_session_path)
    end
  end
end
