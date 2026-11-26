require "rails_helper"

RSpec.describe MenuCatalog do
  let(:catalog) { MenuCatalog.new }

  describe "#current_meal_at" do
    it "devolve o almoço durante o horário do almoço" do
      time = Time.zone.local(2026, 11, 25, 12, 0)
      expect(catalog.current_meal_at(time)).to eq("almoco")
    end

    it "devolve nil fora do horário das refeições" do
      time = Time.zone.local(2026, 11, 25, 10, 0)
      expect(catalog.current_meal_at(time)).to be_nil
    end
  end
end
