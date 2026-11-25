require "rails_helper"

RSpec.describe Access, type: :model do
  let(:restaurante) { Restaurant.create!(name: "RU", campus: "Darcy Ribeiro") }
  let(:catraca) { restaurante.turnstiles.create!(name: "T1", operation: "Ativa") }
  let(:conta) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student")
  end
  let(:estudante) { conta.student }

  def acesso(overrides = {})
    Access.new({
      student: estudante,
      registration: estudante.user,
      restaurant: restaurante,
      turnstile: catraca,
      status: "allowed",
      reason: nil
    }.merge(overrides))
  end

  describe "validações" do
    it "é válido quando o acesso é liberado" do
      expect(acesso).to be_valid
    end

    it "é válido quando bloqueado com motivo" do
      expect(acesso(status: "blocked", reason: "no_balance")).to be_valid
    end

    it "aceita matrícula não cadastrada (estudante nulo)" do
      expect(acesso(student: nil, registration: "239999999", status: "blocked", reason: "not_found"))
        .to be_valid
    end

    it "exige a matrícula digitada" do
      expect(acesso(registration: nil)).not_to be_valid
    end

    it "exige motivo quando bloqueado" do
      expect(acesso(status: "blocked", reason: nil)).not_to be_valid
    end

    it "recusa motivo em acesso liberado" do
      expect(acesso(status: "allowed", reason: "no_balance")).not_to be_valid
    end

    it "recusa status desconhecido" do
      expect(acesso(status: "talvez")).not_to be_valid
    end

    it "recusa motivo desconhecido" do
      expect(acesso(status: "blocked", reason: "sumiu")).not_to be_valid
    end

    it "exige restaurante e catraca" do
      expect(acesso(restaurant: nil)).not_to be_valid
      expect(acesso(turnstile: nil)).not_to be_valid
    end
  end

  describe "associações" do
    it "aparece no histórico do estudante, do restaurante e da catraca" do
      registro = acesso.tap(&:save!)

      expect(estudante.accesses).to include(registro)
      expect(restaurante.accesses).to include(registro)
      expect(catraca.accesses).to include(registro)
    end
  end

  describe "escopos" do
    def criar(**overrides)
      acesso(**overrides).tap(&:save!)
    end

    it "ordena do mais novo para o mais antigo" do
      antigo = criar(created_at: 2.hours.ago)
      novo = criar(created_at: 1.hour.ago)

      expect(Access.newest_first).to eq([ novo, antigo ])
    end

    it "filtra por restaurante" do
      daqui = criar
      outro_restaurante = Restaurant.create!(name: "RU Gama", campus: "Gama")
      outra_catraca = outro_restaurante.turnstiles.create!(name: "T1", operation: "Ativa")
      de_la = criar(restaurant: outro_restaurante, turnstile: outra_catraca)

      expect(Access.for_restaurant(restaurante.id)).to eq([ daqui ])
      expect(Access.for_restaurant(nil)).to match_array([ daqui, de_la ])
    end

    it "filtra por catraca" do
      daqui = criar
      outra = restaurante.turnstiles.create!(name: "T2", operation: "Ativa")
      de_outra = criar(turnstile: outra)

      expect(Access.for_turnstile(outra.id)).to eq([ de_outra ])
      expect(Access.for_turnstile(nil)).to match_array([ daqui, de_outra ])
    end

    describe "por data" do
      it "filtra um dia inteiro" do
        hoje = criar(created_at: Time.zone.today.noon)
        criar(created_at: Time.zone.today.noon - 1.day)

        expect(Access.for_date(Date.current.iso8601)).to contain_exactly(hoje)
      end

      it "não filtra sem data" do
        registro = criar(created_at: Time.zone.today.noon)

        expect(Access.for_date(nil)).to contain_exactly(registro)
        expect(Access.for_date("")).to contain_exactly(registro)
      end

      it "ignora data inválida em vez de quebrar" do
        registro = criar(created_at: Time.zone.today.noon)

        expect(Access.for_date("2026-02-30")).to contain_exactly(registro)
        expect(Access.for_date("ontem")).to contain_exactly(registro)
      end
    end
  end
end
