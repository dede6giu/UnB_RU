require "rails_helper"

RSpec.describe FastPassCycle do
  def turno(refeicao, inicio, fim)
    shift = Shift.create!(meal_type: refeicao, starts_at: inicio, ends_at: fim)
    shift.timeframes.create!(starts_at: inicio, ends_at: Time.zone.parse(inicio) + 15.minutes)
    shift
  end

  def as(hora, minuto)
    Time.zone.local(2026, 11, 18, hora, minuto)
  end

  let!(:cafe) { turno("breakfast", "07:00", "08:30") }
  let!(:almoco) { turno("lunch", "11:15", "14:15") }
  let!(:jantar) { turno("dinner", "17:30", "19:30") }

  describe "#open_shift" do
    it "durante o café, o sorteio aberto é o do almoço" do
      expect(FastPassCycle.new(Shift.all, as(8, 0)).open_shift).to eq(almoco)
    end

    it "depois do jantar, o sorteio aberto é o do café de amanhã" do
      expect(FastPassCycle.new(Shift.all, as(20, 0)).open_shift).to eq(cafe)
    end
  end

  describe "#status_of" do
    it "ativo durante o turno" do
      expect(FastPassCycle.new(Shift.all, as(12, 0)).status_of(almoco)).to eq("active")
    end

    it "pendente entre o resultado do sorteio (1h antes) e o início do turno" do
      ciclo = FastPassCycle.new(Shift.all, as(10, 45))
      expect(ciclo.raffle_time(almoco).strftime("%H:%M")).to eq("10:15")
      expect(ciclo.status_of(almoco)).to eq("pending")
    end

    it "aberto para o próximo sorteio e inativo para os outros" do
      ciclo = FastPassCycle.new(Shift.all, as(9, 0))
      expect(ciclo.status_of(almoco)).to eq("open")
      expect(ciclo.status_of(cafe)).to eq("inactive")
      expect(ciclo.status_of(jantar)).to eq("inactive")
    end

    it "indisponível quando a refeição não tem time-frames" do
      cafe.timeframes.destroy_all
      expect(FastPassCycle.new(Shift.all, as(5, 0)).status_of(cafe)).to eq("unavailable")
    end
  end
end
