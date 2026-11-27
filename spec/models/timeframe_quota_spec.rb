require "rails_helper"

RSpec.describe Timeframe, "cota do FastPass" do
  let(:almoco) { Shift.create!(meal_type: "lunch", starts_at: "11:15", ends_at: "14:15") }
  let(:janela) { almoco.timeframes.create!(starts_at: "12:00", ends_at: "12:15") }

  before do
    restaurante = Restaurant.create!(name: "RU Central", campus: "Darcy Ribeiro")
    Turnstile.create!(name: "Catraca 04", operation: "Ativa", restaurant: restaurante,
                      fastpass_corridor: true, capacity: 40)
  end

  it "aceita de 1 até a capacidade das catracas FastPass" do
    janela.quota = 40
    expect(janela).to be_valid
  end

  it "recusa zero, negativo, texto e acima da capacidade" do
    [ "0", "-5", "abc", "41" ].each do |valor|
      janela.quota = valor
      expect(janela).not_to be_valid, "#{valor} deveria ser inválido"
    end
  end

  it "sem cota própria, vale o padrão do FastPass; com cota, vale a dela" do
    expect(janela.effective_quota).to eq(FastPassSetting.global.default_quota)
    janela.update!(quota: 12)
    expect(janela.effective_quota).to eq(12)
  end
end
