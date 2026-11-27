require "rails_helper"

RSpec.describe FastPassRaffle do
  let(:almoco) { Shift.create!(meal_type: "lunch", starts_at: "11:15", ends_at: "14:15") }
  let(:janela) { almoco.timeframes.create!(starts_at: "12:00", ends_at: "12:15") }

  def inscrever(quantos)
    quantos.times do |i|
      conta = Account.create!(user: "23201234#{i}", password: "senha123", name: "Estudante #{i}", role: "student")
      FastPassEnrollment.create!(student_id: conta.user, timeframe: janela)
    end
  end

  before do
    restaurante = Restaurant.create!(name: "RU Central", campus: "Darcy Ribeiro")
    Turnstile.create!(name: "Catraca 04", operation: "Ativa", restaurant: restaurante,
                      fastpass_corridor: true, capacity: 40)
  end

  it "sorteia no máximo a cota da janela" do
    janela.update!(quota: 2)
    inscrever(3)

    FastPassRaffle.new(janela).draw
    expect(janela.fast_pass_enrollments.where(status: "won").count).to eq(2)
    expect(janela.fast_pass_enrollments.where(status: "lost").count).to eq(1)
  end

  it "com menos inscritos do que vagas, todos ganham" do
    janela.update!(quota: 5)
    inscrever(3)

    FastPassRaffle.new(janela).draw
    expect(janela.fast_pass_enrollments.where(status: "won").count).to eq(3)
    expect(janela.fast_pass_enrollments.where(status: "lost").count).to eq(0)
  end
end
