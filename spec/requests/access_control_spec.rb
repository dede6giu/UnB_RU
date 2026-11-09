require 'rails_helper'

RSpec.describe "AccessControl", type: :request do
  let!(:student_with_balance) { Student.create!(name: 'Alice', registration: '123456', balance: 10.0) }
  let!(:student_without_balance) { Student.create!(name: 'Bob', registration: '654321', balance: 2.0) }

  describe "POST /access_control/check" do
    context "quando o estudante tem saldo suficiente" do
      it "libera o acesso e debita 4.50 do saldo" do
        post "/access_control/check", params: { registration: student_with_balance.registration }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Acesso Liberado")
        expect(student_with_balance.reload.balance).to eq(5.50)
      end
    end

    context "quando o estudante não tem saldo suficiente" do
      it "bloqueia o acesso e não altera o saldo" do
        post "/access_control/check", params: { registration: student_without_balance.registration }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["message"]).to eq("Saldo Insuficiente")
        expect(student_without_balance.reload.balance).to eq(2.0)
      end
    end

    context "quando a matrícula do estudante não está cadastrada" do
      it "retorna erro de estudante não cadastrado" do
        post "/access_control/check", params: { registration: "999999" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["message"]).to eq("Estudante Não Cadastrado")
      end
    end
  end
end
