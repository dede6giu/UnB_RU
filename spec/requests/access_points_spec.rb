require "rails_helper"

RSpec.describe "AccessPoints", type: :request do
  describe "GET /access_point/new" do
    it "mostra a página Configuração de Ponto" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      get new_access_point_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Configuração de Ponto")
    end
    it "redireciona para a página de login do operador se não estiver logado" do
      get new_access_point_path
      expect(response).to redirect_to(new_operator_session_path)
      follow_redirect!
      expect(response.body).to include("Faça login para continuar.")
    end
    it "permite acesso se o operador estiver logado" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      get new_access_point_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Configuração de Ponto")
    end
    it "redireciona para a página de login do operador se o operador não estiver logado" do
      get new_access_point_path
      expect(response).to redirect_to(new_operator_session_path)
      follow_redirect!
      expect(response.body).to include("Faça login para continuar.")
    end
    it "nenhuma catraca escolhida" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: nil } }
      expect(response.body).to include("Escolha um ponto de acesso para iniciar a operação.")
    end
    it "catraca inativa escolhida" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Inativa")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      expect(response.body).to include("O ponto de acesso escolhido está inativo.")
    end
    it "catraca operando escolhida" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Operando")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      expect(response.body).to include("O ponto de acesso escolhido já está em operação.")
    end
    it "catraca ativa escolhida" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Ativa")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      expect(response).to redirect_to(access_point_path)
      follow_redirect!
      expect(response.body).to include("Operação iniciada com sucesso.")
    end
  end
end
