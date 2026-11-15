require "rails_helper"

RSpec.describe Transaction, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student").student
  end
  let(:lancamento) do
    Transaction.new(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 2500)
  end

  it "guarda a matrícula do estudante" do
    expect(lancamento.student_id).to eq("232012345")
  end

  it "não tem acesso quando é uma recarga" do
    expect(lancamento.access_id).to be_nil
  end

  describe "validações" do
    it "é válida como crédito via PIX" do
      expect(lancamento).to be_valid
    end

    it "é inválida com valor zero ou negativo" do
      [ 0, -100 ].each do |valor|
        lancamento.amount_cents = valor
        expect(lancamento).not_to be_valid, "esperava que #{valor} fosse recusado"
      end
    end

    it "é inválida com tipo desconhecido" do
      lancamento.kind = "bonus"
      expect(lancamento).not_to be_valid
    end

    it "é inválida como crédito com meio de pagamento desconhecido" do
      lancamento.payment_method = "boleto"
      expect(lancamento).not_to be_valid
    end

    it "é válida como débito de refeição sem meio de pagamento" do
      lancamento.kind = "debit"
      lancamento.payment_method = nil
      expect(lancamento).to be_valid
    end
  end

  it "separa as refeições das recargas" do
    recarga = Transaction.create!(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 4500)
    refeicao = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450)
    expect(Transaction.debits).to eq([ refeicao ])
    expect(Transaction.credits).to eq([ recarga ])
  end

  it "filtra pelos últimos 30 dias, por este mês ou mostra tudo" do
    travel_to Time.zone.local(2026, 11, 20, 12, 0) do
      antiga = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450, created_at: Time.zone.local(2026, 10, 1))
      mes_passado = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450, created_at: Time.zone.local(2026, 10, 25))
      deste_mes = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450, created_at: Time.zone.local(2026, 11, 5))

      expect(Transaction.in_period("last_30_days")).to contain_exactly(mes_passado, deste_mes)
      expect(Transaction.in_period("this_month")).to contain_exactly(deste_mes)
      expect(Transaction.in_period("all")).to contain_exactly(antiga, mes_passado, deste_mes)
    end
  end

  it "soma o gasto, conta as refeições e soma as recargas" do
    Transaction.create!(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 4500)
    Transaction.create!(student: estudante, kind: "credit", payment_method: "credit_card", amount_cents: 900)
    2.times { Transaction.create!(student: estudante, kind: "debit", amount_cents: 450) }
    expect(Transaction.spent_cents).to eq(900)
    expect(Transaction.meals_count).to eq(2)
    expect(Transaction.recharged_cents).to eq(5400)
  end

  it "filtra por recargas ou refeições, e sem tipo mostra tudo" do
    recarga = Transaction.create!(student: estudante, kind: "credit", payment_method: "pix", amount_cents: 4500)
    refeicao = Transaction.create!(student: estudante, kind: "debit", amount_cents: 450)
    expect(Transaction.of_type("credit")).to eq([ recarga ])
    expect(Transaction.of_type("meal")).to eq([ refeicao ])
    expect(Transaction.of_type(nil)).to contain_exactly(recarga, refeicao)
  end

  it "divide em páginas de 10, com pelo menos uma página" do
    expect(Transaction.total_pages).to eq(1)

    lancamentos = (1..12).map do |i|
      Transaction.create!(student: estudante, kind: "debit", amount_cents: 450, created_at: i.hours.ago)
    end
    do_mais_novo = Transaction.order(created_at: :desc)
    expect(do_mais_novo.page(1)).to eq(lancamentos.first(10))
    expect(do_mais_novo.page(2)).to eq(lancamentos.last(2))
    expect(Transaction.total_pages).to eq(2)
  end
end
