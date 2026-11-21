require "rails_helper"

RSpec.describe "Terminal de Validação", type: :request do
  let!(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante Teste", role: "student").student
  end

  def entrar_e_conectar
    Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
    post operator_session_path, params: { operator: { user: "2000000", password: "senha123" } }
    catraca = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro").turnstiles.create!(name: "T1", operation: "Ativa")
    post access_point_path, params: { access_point: { turnstile_id: catraca.id } }
  end

  def validar(matricula)
    post validate_access_point_path, params: { registration: matricula }
    expect(response).to redirect_to(access_point_path)
    follow_redirect!
  end

  describe "POST /operator/access/validate" do
    it "com saldo, libera, cobra a refeição e mostra o nome e o saldo restante" do
      estudante.update!(balance_cents: 1000)
      entrar_e_conectar
      validar("232012345")
      expect(response.body).to include("Acesso liberado", "Estudante Teste", "232012345", "R$ 5,50")
      expect(estudante.reload.balance_cents).to eq(550)
    end

    it "sem saldo, bloqueia e não cobra" do
      entrar_e_conectar
      validar("232012345")
      expect(response.body).to include("Saldo insuficiente")
      expect(estudante.reload.balance_cents).to eq(0)
    end

    it "com matrícula não cadastrada, bloqueia" do
      entrar_e_conectar
      validar("239999999")
      expect(response.body).to include("Matrícula não cadastrada")
    end

    it "manda para o login quem não entrou como operador" do
      post validate_access_point_path, params: { registration: "232012345" }
      expect(response).to redirect_to(new_operator_session_path)
    end
  end
end
