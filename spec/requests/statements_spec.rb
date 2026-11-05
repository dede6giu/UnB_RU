require "rails_helper"

RSpec.describe "Statements", type: :request do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let!(:estudante) { Student.create!(account: conta, balance_cents: 1800) }

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  def lancar(aluno, kind:, cents:, quando:, payment_method: nil)
    Transaction.create!(student: aluno, kind: kind, amount_cents: cents,
                        payment_method: payment_method, created_at: quando)
  end

  def linhas
    Nokogiri::HTML(response.body).css("tbody tr")
  end

  describe "GET /statement" do
    it "mostra a página Extrato e Histórico de Refeições" do
      entrar
      get statement_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Extrato e Histórico de Refeições")
    end

    it "lista os lançamentos do mais novo para o mais antigo" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 2.days.ago)
      lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago)
      lancar(estudante, kind: "credit", cents: 2250, payment_method: "pix", quando: 1.hour.ago)
      entrar
      get statement_path
      valores = linhas.map { |linha| linha.css("td").last.text.strip }
      expect(valores).to eq([ "+ R$ 22,50", "- R$ 4,50", "+ R$ 45,00" ])
    end

    it "mostra o tipo e o meio de pagamento de cada lançamento" do
      lancar(estudante, kind: "credit", cents: 4500, payment_method: "pix", quando: 2.days.ago)
      lancar(estudante, kind: "debit", cents: 450, quando: 1.day.ago)
      entrar
      get statement_path
      expect(linhas.first.text).to include("Refeição")
      expect(linhas.last.text).to include("Recarga de Saldo").and include("PIX")
    end

    it "mostra a data e a hora no horário de Brasília" do
      lancar(estudante, kind: "debit", cents: 450, quando: Time.utc(2026, 11, 3, 15, 30))
      entrar
      get statement_path
      expect(linhas.first.text).to include("03/11/2026 12:30")
    end

    it "não mostra lançamentos de outro estudante" do
      outra = Account.create!(user: "232054321", password: "senha123", name: "Outra", role: "student")
      colega = Student.create!(account: outra)
      lancar(colega, kind: "credit", cents: 9000, payment_method: "pix", quando: 1.day.ago)
      entrar
      get statement_path
      expect(linhas).to be_empty
      expect(response.body).not_to include("R$ 90,00")
    end

    it "avisa quando ainda não há lançamentos" do
      entrar
      get statement_path
      expect(linhas).to be_empty
      expect(response.body).to include("Você ainda não tem lançamentos.")
    end

    it "manda para o login quem não está autenticado" do
      get statement_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end
end
