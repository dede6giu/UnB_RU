require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student").student
  end
  let(:lancamento) do
    Transaction.new(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 2500)
  end

  it "guarda a matrícula do estudante" do
    expect(lancamento.student_id).to eq("232012345")
  end

  it "não tem acesso quando é uma recarga" do
    expect(lancamento.access_id).to be_nil
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

  it "separa as refeições das recargas" do
    recarga = Transaction.create!(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 4500)
    refeicao = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450)
    expect(Transaction.debits).to eq([ refeicao ])
    expect(Transaction.credits).to eq([ recarga ])
  end
end
