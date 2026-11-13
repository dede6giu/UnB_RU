require 'rails_helper'

RSpec.describe "AccessControl", type: :request do
  let!(:account_with_balance) { Account.create!(user: '232012345', password: 'password', name: 'Alice', role: 'student') }
  let!(:student_with_balance) { account_with_balance.student.tap { |s| s.update!(balance_cents: 1000) } }

  let!(:account_without_balance) { Account.create!(user: '232054321', password: 'password', name: 'Bob', role: 'student') }
  let!(:student_without_balance) { account_without_balance.student.tap { |s| s.update!(balance_cents: 200) } }

  describe "POST /access_control/check" do
    context "quando o estudante tem saldo suficiente" do
      it "libera o acesso e debita do saldo" do
        post "/access_control/check", params: { registration: student_with_balance.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Acesso Liberado")
        expect(student_with_balance.reload.balance_cents).to be < 1000
      end
    end

    context "quando o estudante não tem saldo suficiente" do
      it "bloqueia o acesso e não altera o saldo" do
        post "/access_control/check", params: { registration: student_without_balance.id }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["message"]).to eq("Saldo Insuficiente")
        expect(student_without_balance.reload.balance_cents).to eq(200)
      end
    end

    context "quando a matrícula do estudante não está cadastrada" do
      it "retorna erro de estudante não cadastrado" do
        post "/access_control/check", params: { registration: "999999999" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["message"]).to eq("Estudante Não Cadastrado")
      end
    end
  end
end
