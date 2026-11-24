require "rails_helper"

RSpec.describe Shift, type: :model do
  describe "validações" do
    it "recusa um turno que termina antes de começar" do
      turno = Shift.new(meal_type: "lunch", starts_at: "14:00", ends_at: "11:00")
      expect(turno).not_to be_valid
      expect(turno.errors[:ends_at]).to include("deve ser posterior ao início do turno")
    end

    it "recusa um turno que se sobrepõe a outra refeição, mas aceita turnos que só se encostam" do
      Shift.create!(meal_type: "lunch", starts_at: "11:00", ends_at: "14:00")
      expect(Shift.new(meal_type: "dinner", starts_at: "13:00", ends_at: "15:00")).not_to be_valid
      expect(Shift.new(meal_type: "dinner", starts_at: "14:00", ends_at: "15:00")).to be_valid
    end
  end

  describe ".at" do
    before do
      Shift.create!(meal_type: "breakfast", starts_at: "07:00", ends_at: "09:00")
      Shift.create!(meal_type: "lunch", starts_at: "11:00", ends_at: "14:00")
    end

    it "acha o turno em que o horário cai" do
      expect(Shift.at(Time.zone.local(2026, 11, 24, 12, 30)).meal_type).to eq("lunch")
    end

    it "não acha turno fora dos horários" do
      expect(Shift.at(Time.zone.local(2026, 11, 24, 10, 0))).to be_nil
    end
  end
end
