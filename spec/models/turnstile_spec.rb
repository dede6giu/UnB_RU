require "rails_helper"

RSpec.describe Turnstile, type: :model do
  let(:restaurant) do
    Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
  end
  let(:turnstile) do
    Turnstile.create!(name: "RU 6", restaurant_id: restaurant.id, operation: "Inativa")
  end

  describe "parâmetros" do
    it "é válido com apenas name, operation e restaurant_id preenchidos" do
      expect(turnstile).to be_valid
    end

    it "nome é inválido vazio" do
      turnstile.name = ""
      expect(turnstile).not_to be_valid
    end

    it "operação é inválido vazio" do
      turnstile.operation = ""
      expect(turnstile).not_to be_valid
    end

    it "restaurant_id é inválido vazio" do
      turnstile.restaurant_id = nil
      expect(turnstile).not_to be_valid
    end

    it "operação rejeita valor inválido" do
      turnstile.operation = "Atuando"
      expect(turnstile).not_to be_valid
    end

    %w[ Inativa Ativa Operando FastPass ].each do |mode|
      it "operação aceita #{mode}" do
        turnstile.operation = mode
        expect(turnstile).to be_valid
      end
    end

    it "não podem ser iguais a um turnstile existente" do
      turnstile.reload
      expect { Turnstile.create!(name: "RU 6", restaurant_id: restaurant.id, operation: "Inativa") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "com operador associado" do
    before {
      turnstile.reload
      Account.create!(name: "Fulano da Silva", password: "19661010", role: "operator", user: "1234567")
      turnstile.update!(operator_id: "1234567", operation: "Operando")
    }

    it "permanece válida" do
      expect(turnstile).to be_valid
    end

    it "não é destruída" do
      expect { turnstile.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    %w[ Inativa Ativa ].each do |mode|
      it "não pode estar no modo #{mode}" do
        expect { turnstile.update!(operation: mode) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
