require "rails_helper"

RSpec.describe Student, type: :model do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let(:estudante) { Student.new(account: conta) }

  describe "saldo" do
    it "começa em zero" do
      expect(estudante.balance_cents).to eq(0)
    end

    it "é inválido com saldo negativo" do
      estudante.balance_cents = -1
      expect(estudante).not_to be_valid
    end

    it "é válido com saldo zero" do
      estudante.balance_cents = 0
      expect(estudante).to be_valid
    end
  end

  describe "#add_credit" do
    before { estudante.update!(balance_cents: 1000) }

    it "soma o valor ao saldo" do
      expect(estudante.add_credit(2500, "pix")).to be(true)
      expect(estudante.reload.balance_cents).to eq(3500)
    end

    it "registra uma Transaction de crédito com o meio de pagamento" do
      expect { estudante.add_credit(2500, "credit_card") }.to change { Transaction.count }.by(1)
      lancamento = estudante.transactions.last
      expect(lancamento.kind).to eq("credit")
      expect(lancamento.payment_method).to eq("credit_card")
      expect(lancamento.amount_cents).to eq(2500)
    end

    it "recusa valor zero ou negativo sem mudar o saldo" do
      [ 0, -100 ].each do |valor|
        expect(estudante.add_credit(valor, "pix")).to be(false)
      end
      expect(estudante.balance_cents).to eq(1000)
      expect(estudante.reload.balance_cents).to eq(1000)
      expect(estudante.transactions.count).to eq(0)
    end
  end
end
