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
      turnstile.reload
      expect(turnstile.operator_id).to be_nil
      expect(turnstile.operation).to eq("Inativa")
    end
    it "catraca operando escolhida" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Operando")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      expect(response.body).to include("O ponto de acesso escolhido já está em operação.")
      turnstile.reload
      expect(turnstile.operator_id).to be_nil
      expect(turnstile.operation).to eq("Operando")
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
      turnstile.reload
      expect(turnstile.operator_id).to eq(operator.id)
      expect(turnstile.operation).to eq("Operando")
    end
    it "desconectar do ponto de acesso" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Ativa")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      delete access_point_path
      expect(response).to redirect_to(new_access_point_path)
      follow_redirect!
      expect(response.body).to include("Operação encerrada com sucesso.")
      turnstile.reload
      expect(turnstile.operator_id).to be_nil
      expect(turnstile.operation).to eq("Ativa")
    end
    it "desconectar catraca sem nenhum ponto de acesso em operação" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      delete access_point_path
      expect(response).to redirect_to(new_access_point_path)
      follow_redirect!
      expect(response.body).to include("Nenhum ponto de acesso em operação.")
    end
    it "redireciona para a página de login do operador se o operador não estiver logado ao tentar desconectar" do
      delete access_point_path
      expect(response).to redirect_to(new_operator_session_path)
      follow_redirect!
      expect(response.body).to include("Faça login para continuar.")
    end
    it "redireciona para a página de login do operador se o operador não estiver logado ao tentar iniciar operação" do
      post access_point_path, params: { access_point: { turnstile_id: 1 } }
      expect(response).to redirect_to(new_operator_session_path)
      follow_redirect!
      expect(response.body).to include("Faça login para continuar.")
    end
    it "tenta o ponto de acesso sem catraca em operação redireciona para new access point path" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      get access_point_path
      expect(response).to redirect_to(new_access_point_path)
    end
    it "mostra o terminal com a catraca em operação" do
      restaurant = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      turnstile = restaurant.turnstiles.create!(name: "T1", operation: "Ativa")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      post access_point_path, params: { access_point: { turnstile_id: turnstile.id } }
      get access_point_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Terminal de Validação")
      expect(response.body).to include("T1")
    end
    it "redireciona para a página de login do operador se não estiver logado ao abrir o terminal" do
      get access_point_path
      expect(response).to redirect_to(new_operator_session_path)
    end
    it "redireciona para a página de login do operador se não estiver logado ao abrir a confirmação" do
      get confirm_disconnect_access_point_path
      expect(response).to redirect_to(new_operator_session_path)
    end
    it "confirma desconectar do ponto de acesso" do
      operator = Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
      post operator_session_path, params: { operator: { user: operator.user, password: operator.password } }
      get confirm_disconnect_access_point_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Tem certeza que deseja desconectar do ponto de acesso?")
    end
  end
end
