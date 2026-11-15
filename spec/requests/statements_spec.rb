require "rails_helper"

RSpec.describe "Statements", type: :request do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let!(:estudante) do
    conta.student.update!(balance_cents: 1800)
    conta.student
  end

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  def lancar(aluno, kind:, cents:, quando:, payment_method: nil)
    Transaction.create!(student: aluno, kind: kind, amount_cents: cents,
                        payment_method: payment_method, created_at: quando)
  end

  describe "GET /statement" do
    it "mostra a página Extrato e Histórico de Refeições com o saldo" do
      entrar
      get statement_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Extrato e Histórico de Refeições")
      expect(response.body).to include("R$ 18,00")
    end

    it "lista os lançamentos do mais novo para o mais antigo" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 2.days.ago)
      lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago)
      lancar(estudante, kind: "credit", cents: 2250, payment_method: "pix", quando: 1.hour.ago)
      entrar
      get statement_path
      expect(response.body.index("+ R$ 22,50")).to be < response.body.index("- R$ 4,50")
      expect(response.body.index("- R$ 4,50")).to be < response.body.index("+ R$ 45,00")
    end

    it "mostra o tipo e o meio de pagamento de cada lançamento" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 2.days.ago)
      lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago)
      entrar
      get statement_path
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("PIX")
      expect(response.body).to include("Refeição")
    end

    it "mostra o total gasto, as refeições e o total recarregado" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 3.days.ago)
      lancar(estudante, kind: "credit", cents: 2250, payment_method: "credit_card", quando: 2.days.ago)
      3.times { lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago) }
      entrar
      get statement_path
      expect(response.body).to include("R$ 13,50")
      expect(response.body).to include("3 refeições")
      expect(response.body).to include("R$ 67,50")
    end

    it "mostra os últimos 30 dias por padrão e tudo com o filtro, e os totais acompanham" do
      lancar(estudante, kind: "credit", cents: 9000, payment_method: "pix", quando: 40.days.ago)
      lancar(estudante, kind: "credit", cents: 2250, payment_method: "pix", quando: 5.days.ago)
      entrar

      get statement_path
      expect(response.body).to include("+ R$ 22,50")
      expect(response.body).not_to include("R$ 90,00")

      get statement_path, params: { period: "all" }
      expect(response.body).to include("+ R$ 90,00")
      expect(response.body).to include("R$ 112,50")
    end

    it "avisa quando os filtros não acham nada, mas há lançamentos" do
      lancar(estudante, kind: "credit", cents: 9000, payment_method: "pix", quando: 40.days.ago)
      entrar
      get statement_path
      expect(response.body).to include("Nenhum lançamento com esses filtros.")
      expect(response.body).not_to include("Você ainda não tem lançamentos.")
    end

    it "mostra 10 lançamentos por página e os totais continuam sendo do período inteiro" do
      (1..12).each do |i|
        lancar(estudante, kind: "credit", cents: i * 1000, payment_method: "pix", quando: i.hours.ago)
      end
      entrar

      get statement_path
      expect(response.body).to include("+ R$ 100,00")
      expect(response.body).not_to include("+ R$ 110,00")

      get statement_path, params: { page: 2 }
      expect(response.body).to include("+ R$ 120,00")
      expect(response.body).not_to include("+ R$ 10,00")
      expect(response.body).to include("Página 2 de 2")
      expect(response.body).to include("R$ 780,00")

      get statement_path, params: { page: 99 }
      expect(response.body).to include("Página 2 de 2")
    end

    it "não quebra com uma página que não é número" do
      entrar
      get statement_path, params: { page: [ "2" ] }
      expect(response).to have_http_status(:success)
    end

    it "mantém o período e o tipo escolhidos ao trocar de página" do
      11.times { lancar(estudante, kind: "debit", cents: 450, quando: 40.days.ago) }
      entrar
      get statement_path, params: { period: "all", type: "meal" }
      expect(response.body).to include('href="/statement?page=2&amp;period=all&amp;type=meal"')
    end

    it "filtra por recargas ou refeições, e os totais acompanham" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 2.days.ago)
      2.times { lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago) }
      entrar

      get statement_path, params: { type: "credit" }
      expect(response.body).to include("+ R$ 45,00")
      expect(response.body).not_to include("- R$ 4,50")
      expect(response.body).to include("0 refeições")

      get statement_path, params: { type: "meal" }
      expect(response.body).to include("- R$ 4,50")
      expect(response.body).not_to include("+ R$ 45,00")
      expect(response.body).to include("R$ 9,00")
    end

    it "mostra a data e a hora no horário de Brasília" do
      lancar(estudante, kind: "debit", cents: 450, quando: Time.utc(2026, 11, 3, 15, 30))
      entrar
      get statement_path, params: { period: "all" }
      expect(response.body).to include("03/11/2026 12:30")
    end

    it "não mostra lançamentos de outro estudante" do
      outra = Account.create!(user: "232054321", password: "senha123", name: "Outra", role: "student")
      lancar(outra.student, kind: "credit", cents: 9000, payment_method: "pix", quando: 1.day.ago)
      entrar
      get statement_path
      expect(response.body).not_to include("R$ 90,00")
      expect(response.body).to include("Você ainda não tem lançamentos.")
    end

    it "tem links para o início e a recarga" do
      entrar
      get statement_path
      expect(response.body).to include('href="/student_portal"')
      expect(response.body).to include('href="/recharge/new"')
    end

    it "manda para o login quem não entrou" do
      get statement_path
      expect(response).to redirect_to(new_student_session_path)
    end

    it "tem o botão Exportar PDF com os filtros escolhidos" do
      entrar
      get statement_path, params: { period: "all", type: "meal" }
      expect(response.body).to include('href="/statement.pdf?period=all&amp;type=meal"')
    end
  end

  describe "GET /statement.pdf" do
    def texto_do_pdf
      PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join("\n")
    end

    it "baixa um PDF com todos os lançamentos do filtro, não só os da página" do
      11.times { lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago) }
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 1.day.ago)
      entrar
      get statement_path(format: :pdf), params: { type: "meal" }
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to match(/\Aattachment; filename="extrato-\d{4}-\d{2}-\d{2}\.pdf"/)
      expect(texto_do_pdf.scan("- R$ 4,50").size).to eq(11)
      expect(texto_do_pdf).not_to include("+ R$ 45,00")
    end

    it "sem lançamentos no filtro, volta para o extrato com um aviso" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 40.days.ago)
      entrar
      get statement_path(format: :pdf), params: { period: "this_month" }
      expect(response).to redirect_to(statement_path(period: "this_month"))
      follow_redirect!
      expect(response.body).to include("Não há lançamentos para exportar.")
    end

    it "manda para o login quem não entrou" do
      get statement_path(format: :pdf)
      expect(response).to redirect_to(new_student_session_path)
    end
  end
end
