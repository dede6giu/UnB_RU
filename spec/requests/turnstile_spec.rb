require "rails_helper"

RSpec.describe "Turnstiles", type: :request do
  let!(:conta) do
    Account.create!(user: "1234567", password: "senha123", name: "Meu nome é admin.", role: "admin")
  end
  let!(:restaurant) do
    Restaurant.create!(name: "RU 1", campus: "Planaltina")
  end

  def entrar
    post admin_session_path, params: { admin: { user: "1234567", password: "senha123" } }
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
        get turnstiles_path
        expect(response).to redirect_to(restaurants_path)
      end
    end
  end

  describe "GET /admin/turnstiles/new" do
    context "sem login" do
      it "redireciona para o login de admin" do
        get new_turnstile_path
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "mostra a página de criação de turnstiles" do
        get new_turnstile_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Nova Catraca")
      end
    end
  end

  describe "GET /admin/turnstiles/:id/edit" do
    let!(:turnstile) do
      Turnstile.create!(name: "Principal", operation: "Ativa", restaurant_id: restaurant.id)
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        get edit_turnstile_path(turnstile)
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "mostra a página de edição de turnstile" do
        get edit_turnstile_path(turnstile)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Editar Catraca")
      end
    end
  end

  describe "GET /admin/turnstiles/:id" do
    let!(:turnstile) do
      Turnstile.create!(name: "Principal", operation: "Ativa", restaurant_id: restaurant.id)
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        get turnstile_path(turnstile)
        expect(response).to redirect_to(new_admin_session_path)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants" do
        get turnstile_path(turnstile)
        expect(response).to redirect_to(restaurants_path)
      end
    end
  end

  describe "POST /admin/turnstiles/:id" do
    def criar_turnstile(name:, operation:, restaurant_id:)
      post turnstiles_path, params: { turnstile: { name: name, operation: operation, restaurant_id: restaurant_id }  }
    end

    context "sem login" do
      it "redireciona para o login de admin e não cria a turnstile" do
        criar_turnstile(name: "Principal", operation: "Inativa", restaurant_id: restaurant.id)
        expect(response).to redirect_to(new_admin_session_path)
        expect(Turnstile.count).to eq(0)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e cria a turnstile" do
        criar_turnstile(name: "Principal", operation: "Inativa", restaurant_id: restaurant.id)
        expect(response).to redirect_to(restaurants_path)
        expect(Turnstile.count).to eq(1)
      end

      it "rejeita nome vazio" do
        criar_turnstile(name: "", operation: "Inativa", restaurant_id: restaurant.id)
        expect(response).to have_http_status(:unprocessable_content)
        expect(Turnstile.count).to eq(0)
      end

      it "rejeita operation vazio" do
        criar_turnstile(name: "Principal", operation: "", restaurant_id: restaurant.id)
        expect(response).to have_http_status(:unprocessable_content)
        expect(Turnstile.count).to eq(0)
      end

      it "rejeita operation inválido" do
        criar_turnstile(name: "Principal", operation: "Não é real", restaurant_id: restaurant.id)
        expect(response).to have_http_status(:unprocessable_content)
        expect(Turnstile.count).to eq(0)
      end

      it "rejeita restaurant_id vazio" do
        criar_turnstile(name: "Principal", operation: "Inativa", restaurant_id: nil)
        expect(response).to have_http_status(:unprocessable_content)
        expect(Turnstile.count).to eq(0)
      end

      it "rejeita turnstile existente" do
        criar_turnstile(name: "Principal", operation: "Inativa", restaurant_id: restaurant.id)
        expect(Turnstile.count).to eq(1)
        criar_turnstile(name: "Principal", operation: "Inativa", restaurant_id: restaurant.id)
        expect(response).to have_http_status(:unprocessable_content)
        expect(Turnstile.count).to eq(1)
      end
    end
  end

  describe "DELETE /admin/turnstiles/:id" do
    let!(:turnstile) do
      Turnstile.create!(name: "Principal", operation: "Ativa", restaurant_id: restaurant.id)
    end
    def destruir
      delete turnstile_path(turnstile)
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        destruir
        expect(response).to redirect_to(new_admin_session_path)
        expect(Turnstile.count).to eq(1)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e destrói o turnstile" do
        destruir
        expect(response).to redirect_to(restaurants_path)
        expect(Turnstile.count).to eq(0)
      end

      %w[ Operando FastPass ].each do |mode|
        it "não destrói se o turnstile #{mode} se tem um operador" do
          Account.create!(user: "1000000", name: "operador", role: "operator", password: "operalor")
          turnstile.update!(operation: mode, operator_id: "1000000")
          destruir
          expect(response).to have_http_status(:unprocessable_content)
          expect(Turnstile.count).to eq(1)
        end
      end
    end
  end

  describe "PATCH/PUT /admin/turnstiles/:id" do
    let!(:turnstile) do
      Turnstile.create!(name: "Principal", operation: "Ativa", restaurant_id: restaurant.id)
    end
    let!(:catraca) do
      Turnstile.create!(name: "Prioridade", operation: "Ativa", restaurant_id: restaurant.id)
    end
    let!(:diner) do
      Restaurant.create!(name: "Amarelinho", campus: "Darcy Ribeiro")
    end
    def atualizar(name:, operation:, restaurant_id:)
      patch turnstile_path(turnstile), params: { turnstile: { name: name, operation: operation, restaurant_id: restaurant_id } }
    end

    context "sem login" do
      it "redireciona para o login de admin" do
        atualizar(name: "Exclusiva", operation: "Inativa", restaurant_id: diner.id)
        expect(response).to redirect_to(new_admin_session_path)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end
    end

    context "com login" do
      before { entrar }

      it "redireciona para a página de restaurants e atualiza o restaurant" do
        atualizar(name: "Exclusiva", operation: "Inativa", restaurant_id: diner.id)
        expect(response).to redirect_to(restaurants_path)
        turnstile.reload
        expect(turnstile.name).to eq("Exclusiva")
        expect(turnstile.operation).to eq("Inativa")
        expect(turnstile.restaurant_id).to eq(diner.id)
      end

      it "não aceita nome vazio" do
        atualizar(name: "", operation: "Inativa", restaurant_id: diner.id)
        expect(response).to have_http_status(:unprocessable_content)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end

      it "não aceita operação vazio" do
        atualizar(name: "Exclusiva", operation: "", restaurant_id: diner.id)
        expect(response).to have_http_status(:unprocessable_content)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end

      it "não aceita operação inválido" do
        atualizar(name: "Exclusiva", operation: "Clonar Matrícula", restaurant_id: diner.id)
        expect(response).to have_http_status(:unprocessable_content)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end

      it "não aceita restaurant_id vazio" do
        atualizar(name: "Exclusiva", operation: "Inativa", restaurant_id: nil)
        expect(response).to have_http_status(:unprocessable_content)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end

      it "não aceita turnstile existente" do
        atualizar(name: catraca.name, operation: catraca.operation, restaurant_id: catraca.restaurant_id)
        expect(response).to have_http_status(:unprocessable_content)
        turnstile.reload
        expect(turnstile.name).to eq("Principal")
        expect(turnstile.operation).to eq("Ativa")
        expect(turnstile.restaurant_id).to eq(restaurant.id)
      end
    end
  end
end
