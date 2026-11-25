require "rails_helper"

RSpec.describe GlobalHistoryPdf do
  let(:restaurante) { Restaurant.create!(name: "RU", campus: "Darcy Ribeiro") }
  let(:catraca) { restaurante.turnstiles.create!(name: "T1", operation: "Ativa") }
  let(:aluno) do
    Account.create!(user: "232012345", password: "senha123",
                    name: "Łukasz Kowalski", role: "student").student
  end

  def texto_do(pdf)
    PDF::Reader.new(StringIO.new(pdf)).pages.map(&:text).join("\n")
  end

  def acesso(**overrides)
    Access.create!({
      student: aluno,
      registration: aluno.user,
      restaurant: restaurante,
      turnstile: catraca,
      status: "allowed",
      reason: nil,
      created_at: Time.zone.today.noon
    }.merge(overrides))
  end

  it "traz o título, os filtros e a tabela dos acessos" do
    acesso

    pdf = described_class.new(
      Access.newest_first,
      restaurant: "RU",
      turnstile: "T1",
      date: "25/11/2026"
    ).render
    texto = texto_do(pdf)

    expect(pdf).to start_with("%PDF")
    expect(texto).to include("Histórico Global de Acessos")
    expect(texto).to include("Restaurante: RU")
    expect(texto).to include("Catraca: T1")
    expect(texto).to include("Data: 25/11/2026")
    expect(texto).to include("Łukasz Kowalski")
    expect(texto).to include("232012345")
    expect(texto).to include("Liberado")
    expect(texto).to include("Data e hora")
  end

  it "mostra os rótulos de 'todos' quando não há filtro" do
    acesso

    texto = texto_do(
      described_class.new(Access.all, restaurant: "Todos", turnstile: "Todas", date: "Todas").render
    )

    expect(texto).to include("Restaurante: Todos")
    expect(texto).to include("Catraca: Todas")
    expect(texto).to include("Data: Todas")
  end

  it "mostra acesso bloqueado com o motivo" do
    acesso(status: "blocked", reason: "no_balance")

    texto = texto_do(
      described_class.new(Access.all, restaurant: "Todos", turnstile: "Todas", date: "Todas").render
    )

    expect(texto).to include("Bloqueado")
    expect(texto).to include("no_balance")
  end
end
