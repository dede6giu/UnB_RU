require "rails_helper"

RSpec.describe "Recharges", type: :request do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let!(:estudante) do
    conta.student.update!(balance_cents: 1800)
    conta.student
  end
  let(:cartao) { { card_number: "4111111111111111", card_expiry: "12/99", card_cvv: "987" } }

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  def recarregar(campos)
    post recharge_path, params: { recharge: campos }
  end

  describe "GET /recharge/new" do
    it "mostra o saldo e os pacotes de refeições" do
      entrar
      get new_recharge_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("R$ 18,00")
      expect(response.body).to include("20 Refeições")
      expect(response.body).to include("R$ 90,00")
    end

    it "manda para o login quem não entrou" do
      get new_recharge_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end

  describe "POST /recharge" do
    it "recarrega com PIX e vai para o extrato" do
      entrar
      recarregar(package: "5", payment_method: "pix")
      expect(response).to redirect_to(statement_path)
      expect(estudante.reload.balance_cents).to eq(1800 + 5 * 450)
      expect(estudante.transactions.last.payment_method).to eq("pix")
    end

    it "recarrega com cartão" do
      entrar
      recarregar(cartao.merge(package: "5", payment_method: "credit_card"))
      expect(response).to redirect_to(statement_path)
      expect(estudante.reload.balance_cents).to eq(1800 + 5 * 450)
      expect(estudante.transactions.last.payment_method).to eq("credit_card")
    end

    it "mostra a recarga nova no extrato" do
      entrar
      recarregar(quantity: "5", payment_method: "pix")
      follow_redirect!
      expect(response.body).to include("Recarga realizada com sucesso.")
      expect(response.body).to include("+ R$ 22,50")
    end

    it "recusa quantidade inválida sem mexer no saldo" do
      entrar
      recarregar(quantity: "abc", payment_method: "pix")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Quantidade inválida.")
      expect(estudante.reload.balance_cents).to eq(1800)
    end

    it "não quebra com uma quantidade gigante" do
      entrar
      recarregar(quantity: "99999999999999999999", payment_method: "pix")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Quantidade inválida.")
    end

    it "recusa recarga sem meio de pagamento" do
      entrar
      recarregar(quantity: "2")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Meio de pagamento inválido.")
      expect(estudante.reload.balance_cents).to eq(1800)
    end

    it "recusa cartão inválido sem mexer no saldo" do
      entrar
      recarregar(cartao.merge(card_cvv: "12", package: "5", payment_method: "credit_card"))
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Dados do cartão inválidos.")
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end

    it "volta com o cartão marcado e sem os dados dele depois de um erro" do
      entrar
      recarregar(cartao.merge(quantity: "abc", payment_method: "credit_card"))
      expect(response.body).to include('value="credit_card" checked="checked"')
      expect(response.body).not_to include("4111111111111111")
      expect(response.body).not_to include("987")
    end

    it "não recarrega para quem não entrou" do
      recarregar(package: "5", payment_method: "pix")
      expect(response).to redirect_to(new_student_session_path)
      expect(Transaction.count).to eq(0)
    end
  end

  it "esconde os dados do cartão nos logs" do
    filtro = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtrado = filtro.filter("card_number" => "4111111111111111", "card_expiry" => "12/99", "card_cvv" => "987")
    expect(filtrado["card_number"]).to eq("[FILTERED]")
    expect(filtrado["card_expiry"]).to eq("[FILTERED]")
    expect(filtrado["card_cvv"]).to eq("[FILTERED]")
  end
end
