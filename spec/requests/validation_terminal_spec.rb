require "rails_helper"

RSpec.describe "Terminal de Validação", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:estudante) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante Teste", role: "student").student
  end

  def entrar_e_conectar
    Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")
    post operator_session_path, params: { operator: { user: "2000000", password: "senha123" } }
    catraca = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro").turnstiles.create!(name: "T1", operation: "Ativa")
    post access_point_path, params: { access_point: { turnstile_id: catraca.id } }
  end

  def validar(matricula)
    post validate_access_point_path, params: { registration: matricula }
    expect(response).to redirect_to(access_point_path)
    follow_redirect!
  end

  describe "POST /operator/access/validate" do
    it "com saldo, libera, cobra a refeição e mostra o nome e o saldo restante" do
      estudante.update!(balance_cents: 1000)
      entrar_e_conectar
      validar("232012345")
      expect(response.body).to include("Acesso liberado", "Estudante Teste", "232012345", "R$ 5,50")
      expect(estudante.reload.balance_cents).to eq(550)
    end

    it "sem saldo, bloqueia e não cobra" do
      entrar_e_conectar
      validar("232012345")
      expect(response.body).to include("Saldo insuficiente")
      expect(estudante.reload.balance_cents).to eq(0)
    end

    it "com matrícula não cadastrada, bloqueia" do
      entrar_e_conectar
      validar("239999999")
      expect(response.body).to include("Matrícula não cadastrada")
    end

    it "manda para o login quem não entrou como operador" do
      post validate_access_point_path, params: { registration: "232012345" }
      expect(response).to redirect_to(new_operator_session_path)
    end

    describe "registro no histórico global" do
      it "registra acesso liberado com restaurante e catraca" do
        estudante.update!(balance_cents: 1000)
        entrar_e_conectar

        expect { validar("232012345") }.to change(Access, :count).by(1)

        acesso = Access.last
        expect(acesso).to have_attributes(status: "allowed", reason: nil, student_id: "232012345")
        expect(acesso.restaurant.name).to eq("RU")
        expect(acesso.turnstile.name).to eq("T1")
      end

      it "registra bloqueio por saldo insuficiente" do
        entrar_e_conectar

        expect { validar("232012345") }.to change(Access, :count).by(1)

        expect(Access.last).to have_attributes(status: "blocked", reason: "no_balance")
      end

      it "registra bloqueio de matrícula não cadastrada sem estudante" do
        entrar_e_conectar

        expect { validar("239999999") }.to change(Access, :count).by(1)

        acesso = Access.last
        expect(acesso).to have_attributes(status: "blocked", reason: "not_found", student_id: nil, registration: "239999999")
      end

      it "vincula o débito da refeição ao acesso liberado" do
        estudante.update!(balance_cents: 1000)
        entrar_e_conectar

        expect { validar("232012345") }
          .to change(Transaction.debits, :count).by(1)
          .and change(Access, :count).by(1)

        expect(Transaction.debits.last.access).to eq(Access.last)
      end

      it "grava no acesso o turno da refeição" do
        Shift.create!(meal_type: "lunch", starts_at: "11:00", ends_at: "14:00")
        estudante.update!(balance_cents: 1000)
        entrar_e_conectar

        travel_to Time.zone.local(2026, 11, 24, 12, 0) do
          validar("232012345")
        end

        expect(Access.last.shift.meal_type).to eq("lunch")
      end
    end
  end
end
