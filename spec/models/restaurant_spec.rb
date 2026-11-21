require "rails_helper"

RSpec.describe Restaurant, type: :model do
  let(:restaurant) do
    Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")
  end

  describe "parâmetros" do
    it "é válido com todos os campos preenchidos" do
      expect(restaurant).to be_valid
    end

    it "nome é inválido vazio" do
      restaurant.name = ""
      expect(restaurant).not_to be_valid
    end

    it "campus é inválido vazio" do
      restaurant.campus = ""
      expect(restaurant).not_to be_valid
    end

    it "não podem ser iguais a um restaurante existente" do
      restaurant.reload
      expect { Restaurant.create!(name: "RU", campus: "Darcy Ribeiro") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "turnstile" do
    it "começa com zero" do
      expect(Turnstile.where(restaurant_id: restaurant.id).count).to eq(0)
    end

    it "não destrói se turnstiles associadas estiverem em operação" do
      Turnstile.create!(name: "RU 6", restaurant_id: restaurant.id, operation: "Operando")
      expect { restaurant.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end
end
