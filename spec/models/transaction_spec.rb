require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:estudante) do
    conta = Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
    Student.create!(account: conta)
  end
  let(:lancamento) do
    Transaction.new(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 2500)
  end

  describe "validações" do
    it "é válida como crédito via PIX" do
      expect(lancamento).to be_valid
    end

    it "é inválida com valor zero ou negativo" do
      [ 0, -100 ].each do |valor|
        lancamento.amount_cents = valor
        expect(lancamento).not_to be_valid, "esperava que #{valor} fosse recusado"
      end
    end

    it "é inválida com tipo desconhecido" do
      lancamento.kind = "bonus"
      expect(lancamento).not_to be_valid
    end

    it "é inválida como crédito com meio de pagamento desconhecido" do
      lancamento.payment_method = "boleto"
      expect(lancamento).not_to be_valid
    end

    it "é válida como débito de refeição sem meio de pagamento" do
      lancamento.kind = "debit"
      lancamento.payment_method = nil
      expect(lancamento).to be_valid
    end
  end
end
