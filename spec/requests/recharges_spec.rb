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

  describe "POST /recharge com PIX" do
    def recarregar(quantidade)
      post recharge_path, params: { recharge: { payment_method: "pix", quantity: quantidade } }
    end

    it "soma as refeições ao saldo e registra o lançamento PIX" do
      entrar
      expect { recarregar(5) }.to change { Transaction.count }.by(1)
      expect(estudante.reload.balance_cents).to eq(1800 + 5 * 450)
      expect(estudante.transactions.last.payment_method).to eq("pix")
      expect(response).to redirect_to(student_portal_path)
      expect(flash[:notice]).to eq("Recarga realizada com sucesso.")
    end

    it "recusa quantidade inválida sem mudar o saldo" do
      entrar
      [ "0", "-3", "abc", "", "2.5" ].each do |quantidade|
        recarregar(quantidade)
        expect(response).to have_http_status(:unprocessable_entity), "esperava recusar #{quantidade.inspect}"
        expect(response.body).to include("Quantidade inválida.")
      end
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end

    it "não recarrega para quem não está autenticado" do
      recarregar(5)
      expect(response).to redirect_to(new_student_session_path)
      expect(Transaction.count).to eq(0)
    end
  end
end
