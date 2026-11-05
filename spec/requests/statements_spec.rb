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

    it "mostra a data e a hora no horário de Brasília" do
      lancar(estudante, kind: "debit", cents: 450, quando: Time.utc(2026, 11, 3, 15, 30))
      entrar
      get statement_path
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

    it "manda para o login quem não entrou" do
      get statement_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end
end
