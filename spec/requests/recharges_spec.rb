require "rails_helper"

RSpec.describe "Recharges", type: :request do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let!(:estudante) { Student.create!(account: conta, balance_cents: 1800) }

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  describe "GET /recharge/new" do
    it "mostra a página Recarga de Saldo com o saldo atual" do
      entrar
      get new_recharge_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("R$ 18,00")
    end

    it "oferece os pacotes de 2, 5, 10 e 20 refeições a R$ 4,50 cada" do
      entrar
      get new_recharge_path
      [ [ 2, "R$ 9,00" ], [ 5, "R$ 22,50" ], [ 10, "R$ 45,00" ], [ 20, "R$ 90,00" ] ].each do |quantidade, preco|
        expect(response.body).to include("#{quantidade} Refeições")
        expect(response.body).to include(preco)
      end
    end

    it "manda para o login quem não está autenticado" do
      get new_recharge_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end
end
