require "rails_helper"

RSpec.describe "Recharges", type: :request do
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let!(:estudante) { Student.create!(account: conta, balance_cents: 1800) }

  def entrar
    post student_session_path, params: { student: { user: "232012345", password: "senha123" } }
  end

  describe "GET /recharge/new" do
    it "mostra a página Recarga de Saldo com o saldo atual" do
      entrar
      get new_recharge_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("R$ 18,00")
    end

    it "oferece os pacotes de 2, 5, 10 e 20 refeições a R$ 4,50 cada" do
      entrar
      get new_recharge_path
      [ [ 2, "R$ 9,00" ], [ 5, "R$ 22,50" ], [ 10, "R$ 45,00" ], [ 20, "R$ 90,00" ] ].each do |quantidade, preco|
        expect(response.body).to include("#{quantidade} Refeições")
        expect(response.body).to include(preco)
      end
    end

    it "mostra o formulário de recarga com PIX" do
      entrar
      get new_recharge_path
      formulario = Nokogiri::HTML(response.body).at_css('form[action="/recharge"][method="post"]')
      expect(formulario).not_to be_nil
      pacotes = formulario.css('input[type="radio"][name="recharge[package]"]').map { |campo| campo["value"] }
      expect(pacotes).to eq(%w[2 5 10 20])
      expect(formulario.at_css('input#credit-amount[name="recharge[quantity]"]')).not_to be_nil
      expect(formulario.at_css('button[type="submit"]').text).to include("Confirmar")
    end

    it "manda para o login quem não está autenticado" do
      get new_recharge_path
      expect(response).to redirect_to(new_student_session_path)
    end
  end

  describe "POST /recharge com PIX" do
    def recarregar(quantidade = nil, pacote: nil)
      campos = { payment_method: "pix", quantity: quantidade, package: pacote }.compact
      post recharge_path, params: { recharge: campos }
    end

    it "soma as refeições ao saldo e registra o lançamento PIX" do
      entrar
      expect { recarregar(5) }.to change { Transaction.count }.by(1)
      expect(estudante.reload.balance_cents).to eq(1800 + 5 * 450)
      expect(estudante.transactions.last.payment_method).to eq("pix")
      expect(response).to redirect_to(statement_path)
      expect(flash[:notice]).to eq("Recarga realizada com sucesso.")
    end

    it "mostra no extrato a mensagem de sucesso e a nova entrada PIX" do
      entrar
      recarregar(5)
      follow_redirect!
      expect(response.body).to include("Recarga realizada com sucesso.")
      linha = Nokogiri::HTML(response.body).at_css("tbody tr").text
      expect(linha).to include("Recarga de Saldo").and include("PIX").and include("+ R$ 22,50")
    end

    it "recusa quantidade inválida sem mudar o saldo" do
      entrar
      [ "0", "-3", "abc", "", "2.5" ].each do |quantidade|
        recarregar(quantidade)
        expect(response).to have_http_status(:unprocessable_entity), "esperava recusar #{quantidade.inspect}"
        expect(response.body).to include("Quantidade inválida.")
      end
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end

    it "usa o pacote escolhido quando \"outra quantidade\" está vazia" do
      entrar
      recarregar("", pacote: "10")
      expect(estudante.reload.balance_cents).to eq(1800 + 10 * 450)
    end

    it "usa a \"outra quantidade\" quando preenchida, mesmo com pacote escolhido" do
      entrar
      recarregar("3", pacote: "10")
      expect(estudante.reload.balance_cents).to eq(1800 + 3 * 450)
    end

    it "recusa \"outra quantidade\" inválida sem cair no pacote escolhido" do
      entrar
      recarregar("abc", pacote: "5")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(estudante.reload.balance_cents).to eq(1800)
    end

    it "não recarrega para quem não está autenticado" do
      recarregar(5)
      expect(response).to redirect_to(new_student_session_path)
      expect(Transaction.count).to eq(0)
    end
  end
end
