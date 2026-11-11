require "rails_helper"

RSpec.describe StatementPdf do
  # nome com letra que não existe nas fontes que já vêm no PDF: sem a DejaVu, a exportação quebrava
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Łukasz Kowalski", role: "student")
  end
  let(:estudante) do
    conta.student.update!(balance_cents: 1800)
    conta.student
  end

  def texto_do(pdf)
    PDF::Reader.new(StringIO.new(pdf)).pages.map(&:text).join("\n")
  end

  it "tem o estudante, os filtros, os totais e os lançamentos" do
    Transaction.create!(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 4500, created_at: 2.days.ago)
    Transaction.create!(student: estudante, kind: "debit", amount_cents: 450, created_at: 1.day.ago)

    pdf = StatementPdf.new(estudante, estudante.transactions, period: "all", type: nil).render
    texto = texto_do(pdf)

    expect(pdf).to start_with("%PDF")
    expect(texto).to include("Extrato e Histórico de Refeições")
    expect(texto).to include("Łukasz Kowalski")
    expect(texto).to include("232012345")
    expect(texto).to include("Período: Todo o período")
    expect(texto).to include("Tipo: Todos")
    expect(texto).to include("Total gasto: R$ 4,50")
    expect(texto).to include("Refeições: 1")
    expect(texto).to include("Total recarregado: R$ 45,00")
    expect(texto).to include("Saldo atual: R$ 18,00")
    expect(texto).to include("+ R$ 45,00")
    expect(texto).to include("- R$ 4,50")
  end
end
