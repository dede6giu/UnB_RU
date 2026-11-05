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

    it "oferece PIX (marcado) e cartão de crédito como meios de pagamento" do
      entrar
      get new_recharge_path
      meios = Nokogiri::HTML(response.body).css('form input[type="radio"][name="recharge[payment_method]"]')
      expect(meios.map { |campo| campo["value"] }).to eq(%w[pix credit_card])
      expect(meios.select { |campo| campo["checked"] }.map { |campo| campo["value"] }).to eq(%w[pix])
    end

    it "mostra os campos do cartão com os ids do .feature" do
      entrar
      get new_recharge_path
      formulario = Nokogiri::HTML(response.body).at_css("form")
      {
        "card-number" => [ "recharge[card_number]", "cc-number" ],
        "card-expire" => [ "recharge[card_expiry]", "cc-exp" ],
        "card-secure" => [ "recharge[card_cvv]", "cc-csc" ]
      }.each do |id, (nome, autocomplete)|
        campo = formulario.at_css("input##{id}")
        expect(campo).not_to be_nil, "faltou o campo #{id}"
        expect(campo["name"]).to eq(nome)
        expect(campo["autocomplete"]).to eq(autocomplete)
      end
    end

    it "mostra os painéis do PIX e do cartão" do
      entrar
      get new_recharge_path
      pagina = Nokogiri::HTML(response.body)
      expect(pagina.at_css("#pix-panel")).not_to be_nil
      expect(pagina.at_css("#card-panel")).not_to be_nil
      expect(pagina.at_css("#card-panel").css("input").size).to eq(3)
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

    it "recusa meio de pagamento desconhecido" do
      entrar
      post recharge_path, params: { recharge: { payment_method: "boleto", quantity: "5" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Meio de pagamento inválido.")
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end
  end

  describe "POST /recharge com cartão de crédito" do
    let(:cartao) { { card_number: "4111111111111111", card_expiry: "12/99", card_cvv: "123" } }

    def recarregar_no_cartao(quantidade = "5", **dados)
      campos = { payment_method: "credit_card", quantity: quantidade }.merge(dados)
      post recharge_path, params: { recharge: campos }
    end

    it "soma as refeições ao saldo e registra o lançamento de cartão" do
      entrar
      expect { recarregar_no_cartao("5", **cartao) }.to change { Transaction.count }.by(1)
      expect(estudante.reload.balance_cents).to eq(1800 + 5 * 450)
      expect(estudante.transactions.last.payment_method).to eq("credit_card")
      expect(response).to redirect_to(statement_path)
      expect(flash[:notice]).to eq("Recarga realizada com sucesso.")
    end

    it "mostra no extrato a nova entrada de cartão" do
      entrar
      recarregar_no_cartao("5", **cartao)
      follow_redirect!
      linha = Nokogiri::HTML(response.body).at_css("tbody tr").text
      expect(linha).to include("Recarga de Saldo").and include("Cartão de Crédito").and include("+ R$ 22,50")
    end

    it "recusa dados do cartão inválidos sem mudar o saldo" do
      entrar
      [ { card_number: "4111" }, { card_expiry: "13/99" }, { card_expiry: "01/20" }, { card_cvv: "12" } ].each do |erro|
        recarregar_no_cartao("5", **cartao.merge(erro))
        expect(response).to have_http_status(:unprocessable_entity), "esperava recusar #{erro}"
        expect(response.body).to include("Dados do cartão inválidos.")
      end
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end

    it "recusa quando os dados do cartão não foram enviados" do
      entrar
      recarregar_no_cartao("5")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Dados do cartão inválidos.")
      expect(Transaction.count).to eq(0)
    end

    it "recusa quantidade inválida mesmo com cartão correto" do
      entrar
      recarregar_no_cartao("abc", **cartao)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Quantidade inválida.")
      expect(estudante.reload.balance_cents).to eq(1800)
      expect(Transaction.count).to eq(0)
    end

    it "não devolve os dados do cartão na página de erro" do
      entrar
      recarregar_no_cartao("abc", **cartao)
      expect(response.body).not_to include("4111111111111111")
      expect(response.body).not_to include("123")
    end

    it "mantém o cartão selecionado e os campos vazios depois de um erro" do
      entrar
      recarregar_no_cartao("abc", **cartao)
      pagina = Nokogiri::HTML(response.body)
      marcado = pagina.css('input[name="recharge[payment_method]"]').select { |campo| campo["checked"] }
      expect(marcado.map { |campo| campo["value"] }).to eq(%w[credit_card])
      %w[card-number card-expire card-secure].each do |id|
        expect(pagina.at_css("input##{id}")["value"]).to be_blank
      end
    end

    it "mantém o PIX selecionado depois de um erro com PIX" do
      entrar
      post recharge_path, params: { recharge: { payment_method: "pix", quantity: "abc" } }
      marcado = Nokogiri::HTML(response.body).css('input[name="recharge[payment_method]"]').select { |campo| campo["checked"] }
      expect(marcado.map { |campo| campo["value"] }).to eq(%w[pix])
    end

    it "não grava o número do cartão nos logs" do
      filtro = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      filtrado = filtro.filter("recharge" => cartao.transform_keys(&:to_s))
      expect(filtrado.to_s).not_to include("4111111111111111")
      expect(filtrado.to_s).not_to include("123")
    end
  end
end
