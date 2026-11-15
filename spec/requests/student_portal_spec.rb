require "rails_helper"

RSpec.describe "StudentPortal", type: :request do
  let!(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  describe "GET /student_portal" do
    context "logado" do
      before { entrar }

      it "mostra a página Portal do Estudante" do
        get student_portal_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Portal do Estudante")
      end

      it "tem links para a recarga e o extrato" do
        get student_portal_path
        expect(response.body).to include('href="/recharge/new"')
        expect(response.body).to include('href="/statement"')
      end

      it "mostra o saldo" do
        conta.student.update!(balance_cents: 1550)
        get student_portal_path
        expect(response.body).to include("R$ 15,50")
      end
    end

    context "sem login" do
      it "redireciona para o login do estudante" do
        get student_portal_path
        expect(response).to redirect_to(new_student_session_path)
      end
    end
  end
end
