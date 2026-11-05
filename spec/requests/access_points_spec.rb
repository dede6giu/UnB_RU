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
  end
end
