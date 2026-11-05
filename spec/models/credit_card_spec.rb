require "rails_helper"

RSpec.describe CreditCard, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:cartao) { CreditCard.new(number: "4111111111111111", expiry: "12/99", cvv: "123") }

  describe "validações" do
    it "é válido com número, validade e CVV corretos" do
      expect(cartao).to be_valid
    end

    it "é inválido se o número não tiver 16 dígitos" do
      [ "411111111111111", "41111111111111111", "4111 1111 1111 111a", "" ].each do |numero|
        cartao.number = numero
        expect(cartao).not_to be_valid, "esperava que #{numero.inspect} fosse recusado"
      end
    end

    it "é inválido se o CVV não tiver 3 dígitos" do
      [ "12", "1234", "12a", "" ].each do |codigo|
        cartao.cvv = codigo
        expect(cartao).not_to be_valid, "esperava que #{codigo.inspect} fosse recusado"
      end
    end

    it "é inválido se a validade não estiver no formato MM/AA" do
      [ "1299", "13/99", "00/99", "1/99", "" ].each do |validade|
        cartao.expiry = validade
        expect(cartao).not_to be_valid, "esperava que #{validade.inspect} fosse recusado"
      end
    end

    it "é inválido com validade no passado" do
      cartao.expiry = "01/20"
      expect(cartao).not_to be_valid
    end

    it "é válido com validade no mês atual" do
      cartao.expiry = Date.current.strftime("%m/%y")
      expect(cartao).to be_valid
    end

    it "aceita o número com espaços, como vem impresso no cartão" do
      cartao.number = "4111 1111 1111 1111"
      expect(cartao).to be_valid
    end

    it "usa a data de Brasília para saber se venceu" do
      # 22h de 30/11 em Brasília já é 1º/12 em UTC
      travel_to Time.utc(2026, 12, 1, 1, 0) do
        cartao.expiry = "11/26"
        expect(cartao).to be_valid
      end
    end
  end
end
