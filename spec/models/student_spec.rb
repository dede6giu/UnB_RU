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
    it "soma o valor ao saldo"
    it "registra uma Transaction de crédito com o meio de pagamento"
    it "recusa valor zero ou negativo sem mudar o saldo"
  end
end
