require "rails_helper"

RSpec.describe Recharge, type: :model do
  let(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student").student
  end
  let(:recarga) { Recharge.new(student: estudante, package: "5", payment_method: "pix") }

  describe "quantidade" do
    it "usa o pacote escolhido" do
      expect(recarga.amount_cents).to eq(5 * 450)
    end

    it "usa a outra quantidade quando ela é preenchida" do
      recarga.quantity = "3"
      expect(recarga.amount_cents).to eq(3 * 450)
    end

    it "lê 010 como dez refeições" do
      recarga.quantity = "010"
      expect(recarga).to be_valid
      expect(recarga.amount_cents).to eq(10 * 450)
    end

    it "recusa o que não for um número inteiro maior que zero" do
      [ "0", "-3", "abc", "2.5", "0x10", "1_0" ].each do |quantidade|
        recarga.quantity = quantidade
        expect(recarga).not_to be_valid, "esperava recusar #{quantidade}"
        expect(recarga.errors.first.message).to eq("Quantidade inválida.")
      end
    end

    it "aceita até 100 refeições" do
      recarga.quantity = "100"
      expect(recarga).to be_valid
      recarga.quantity = "101"
      expect(recarga).not_to be_valid
    end
  end

  describe "pagamento" do
    it "recusa recarga sem meio de pagamento" do
      recarga.payment_method = nil
      expect(recarga).not_to be_valid
      expect(recarga.errors.first.message).to eq("Meio de pagamento inválido.")
    end

    it "confere o cartão quando o pagamento é no cartão" do
      recarga.payment_method = "credit_card"
      expect(recarga).not_to be_valid
      expect(recarga.errors.first.message).to eq("Dados do cartão inválidos.")

      recarga.card_number = "4111111111111111"
      recarga.card_expiry = "12/99"
      recarga.card_cvv = "123"
      expect(recarga).to be_valid
    end

    it "avisa da quantidade antes do cartão" do
      recarga.quantity = "abc"
      recarga.payment_method = "credit_card"
      recarga.valid?
      expect(recarga.errors.first.message).to eq("Quantidade inválida.")
    end
  end

  describe "#save" do
    it "soma as refeições no saldo" do
      expect(recarga.save).to be(true)
      expect(estudante.reload.balance_cents).to eq(5 * 450)
    end

    it "não mexe no saldo quando a recarga é inválida" do
      recarga.quantity = "abc"
      expect(recarga.save).to be(false)
      expect(estudante.reload.balance_cents).to eq(0)
    end
  end
end
