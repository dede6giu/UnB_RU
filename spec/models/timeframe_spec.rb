require "rails_helper"

RSpec.describe Timeframe, "horário da janela" do
  let(:almoco) { Shift.create!(meal_type: "lunch", starts_at: "11:15", ends_at: "14:15") }

  it "aceita uma janela dentro do turno" do
    janela = almoco.timeframes.build(starts_at: "12:00", ends_at: "12:15")
    expect(janela).to be_valid
  end

  it "recusa uma janela que sai do turno" do
    janela = almoco.timeframes.build(starts_at: "14:00", ends_at: "14:30")
    expect(janela).not_to be_valid
    expect(janela.errors[:base]).to include("O time-frame deve estar dentro do turno da refeição.")
  end

  it "recusa uma janela que termina antes de começar" do
    janela = almoco.timeframes.build(starts_at: "12:15", ends_at: "12:00")
    expect(janela).not_to be_valid
    expect(janela.errors[:ends_at]).to include("deve ser posterior ao início do time-frame")
  end
end
