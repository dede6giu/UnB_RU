require "rails_helper"

RSpec.describe Account, type: :model do
  let(:conta) do
    Account.new(user: "1234567", password: "senha123", name: "Alguém", role: "admin")
  end

  describe "validações" do
    it "é válida com todos os campos preenchidos" do
      expect(conta).to be_valid
    end

    it "aceita os papéis admin, operator e student" do
      { "admin" => "1234567", "operator" => "1234567", "student" => "232012345" }.each do |papel, matricula|
        conta.role = papel
        conta.user = matricula
        expect(conta).to be_valid, "esperava que o papel #{papel} fosse aceito"
      end
    end

    it "é inválida sem matrícula" do
      conta.user = nil
      expect(conta).not_to be_valid
    end

    it "é inválida sem senha" do
      conta.password = nil
      expect(conta).not_to be_valid
    end

    it "é inválida sem nome" do
      conta.name = nil
      expect(conta).not_to be_valid
    end

    it "é inválida sem papel" do
      conta.role = nil
      expect(conta).not_to be_valid
    end

    it "é inválida com um papel desconhecido" do
      conta.role = "visitante"
      expect(conta).not_to be_valid
    end

    it "é inválida com uma matrícula já usada por outra conta" do
      Account.create!(user: "1234567", password: "outra123", name: "Beltrano", role: "operator")
      expect(conta).not_to be_valid
    end
  end

  describe "senha" do
    it "é válida com 8 caracteres" do
      conta.password = "12345678"
      expect(conta).to be_valid
    end

    it "é inválida com menos de 8 caracteres" do
      conta.password = "1234567"
      expect(conta).not_to be_valid
    end
  end

  describe "matrícula de admin e operador" do
    %w[admin operator].each do |papel|
      context "quando o papel é #{papel}" do
        before { conta.role = papel }

        it "é válida com 7 dígitos" do
          conta.user = "7654321"
          expect(conta).to be_valid
        end

        it "é inválida com 6 dígitos" do
          conta.user = "123456"
          expect(conta).not_to be_valid
        end

        it "é inválida com 9 dígitos" do
          conta.user = "232012345"
          expect(conta).not_to be_valid
        end

        it "é inválida com letras" do
          conta.user = "12345ab"
          expect(conta).not_to be_valid
        end
      end
    end
  end

  describe "matrícula de estudante" do
    before { conta.role = "student" }

    it "é válida no formato AA SS DDDDD" do
      %w[001012345 192054321 261099999].each do |matricula|
        conta.user = matricula
        expect(conta).to be_valid, "esperava que #{matricula} fosse aceita"
      end
    end

    it "é inválida com ano depois de 26" do
      conta.user = "271012345"
      expect(conta).not_to be_valid
    end

    it "é inválida com semestre diferente de 10 ou 20" do
      conta.user = "233012345"
      expect(conta).not_to be_valid
    end

    it "é inválida com 7 dígitos" do
      conta.user = "1234567"
      expect(conta).not_to be_valid
    end

    it "é inválida com letras" do
      conta.user = "2320abcde"
      expect(conta).not_to be_valid
    end
  end

  describe "#authenticate" do
    before { conta.save! }

    it "devolve a conta com a senha certa" do
      expect(conta.authenticate("senha123")).to eq(conta)
    end

    it "devolve false com a senha errada" do
      expect(conta.authenticate("errada99")).to be(false)
    end

    it "não guarda a senha em texto puro" do
      expect(conta.password_digest).not_to eq("senha123")
    end
  end

  describe "carteira do estudante" do
    it "cria a carteira com saldo zero junto com a conta de estudante" do
      conta.role = "student"
      conta.user = "232012345"
      conta.save!
      expect(conta.student).to be_persisted
      expect(conta.student.balance_cents).to eq(0)
    end

    it "não cria carteira para admin nem operador" do
      { "admin" => "1234567", "operator" => "7654321" }.each do |papel, matricula|
        outra = Account.create!(user: matricula, password: "senha123", name: "Alguém", role: papel)
        expect(outra.student).to be_nil, "esperava que #{papel} não tivesse carteira"
      end
    end
  end
end
