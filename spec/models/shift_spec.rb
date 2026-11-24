require "rails_helper"

RSpec.describe Shift, type: :model do
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
