require "rails_helper"

RSpec.describe "Histórico Global", type: :request do
  let!(:admin) do
    Account.create!(user: "1000000", password: "senha123", name: "Admin", role: "admin")
  end
  let!(:restaurante) { Restaurant.create!(name: "RU", campus: "Darcy Ribeiro") }
  let!(:catraca) { restaurante.turnstiles.create!(name: "T1", operation: "Ativa") }
  let!(:aluno) do
    Account.create!(user: "232012345", password: "senha123", name: "Estudante", role: "student").student
  end

  def entrar_como_admin
    post admin_session_path, params: { admin: { user: "1000000", password: "senha123" } }
  end

  def criar_acesso(quando:, restaurant: restaurante, turnstile: catraca,
                   status: "allowed", student: aluno)
    Access.create!(
      student: student,
      registration: student&.user || "239999999",
      restaurant: restaurant,
      turnstile: turnstile,
      status: status,
      reason: status == "blocked" ? "no_balance" : nil,
      created_at: quando
    )
  end

  it "manda para o login quem não entrou" do
    get global_history_path
    expect(response).to redirect_to(new_admin_session_path)
  end

  it "responde 200 para um admin autenticado" do
    entrar_como_admin
    get global_history_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Histórico Global")
  end

  it "mostra o acesso mais novo primeiro" do
    antigo = criar_acesso(quando: 2.hours.ago)
    novo = criar_acesso(quando: 1.hour.ago)

    entrar_como_admin
    get global_history_path

    expect(response.body.index("access_#{novo.id}"))
      .to be < response.body.index("access_#{antigo.id}")
  end

  it "filtra por restaurante" do
    daqui = criar_acesso(quando: 1.hour.ago)

    outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
    outra_catraca = outro.turnstiles.create!(name: "T1", operation: "Ativa")
    de_la = criar_acesso(quando: 1.hour.ago, restaurant: outro, turnstile: outra_catraca)

    entrar_como_admin
    get global_history_path, params: { restaurant_id: restaurante.id }

    expect(response.body).to include("access_#{daqui.id}")
    expect(response.body).not_to include("access_#{de_la.id}")
  end

  it "filtra por catraca" do
    daqui = criar_acesso(quando: 1.hour.ago)
    outra = restaurante.turnstiles.create!(name: "T2", operation: "Ativa")
    de_outra = criar_acesso(quando: 1.hour.ago, turnstile: outra)

    entrar_como_admin
    get global_history_path, params: { turnstile_id: catraca.id }

    expect(response.body).to include("access_#{daqui.id}")
    expect(response.body).not_to include("access_#{de_outra.id}")
  end

  it "mostra só as catracas do restaurante filtrado" do
    outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
    outro.turnstiles.create!(name: "T9", operation: "Ativa")

    entrar_como_admin
    get global_history_path, params: { restaurant_id: restaurante.id }

    expect(response.body).to include("T1")
    expect(response.body).not_to include("T9")
  end

  it "identifica a catraca pelo restaurante quando há nomes repetidos" do
    outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
    outro.turnstiles.create!(name: "T1", operation: "Ativa")

    entrar_como_admin
    get global_history_path

    expect(response.body).to include("RU - T1")
    expect(response.body).to include("RU Gama - T1")
  end

  it "destaca o link do histórico no menu do admin" do
    entrar_como_admin
    get global_history_path

    pagina = Nokogiri::HTML(response.body)
    historico = pagina.at_css('a[href="/admin/history"]')
    gestao = pagina.at_css('a[href="/admin/restaurants"]')

    expect(historico["class"]).to include("nav-link active")
    expect(gestao["class"]).not_to include("active")
  end

  it "mantém o link de gestão ativo na página de restaurantes" do
    entrar_como_admin
    get restaurants_path

    pagina = Nokogiri::HTML(response.body)
    gestao = pagina.at_css('a[href="/admin/restaurants"]')
    historico = pagina.at_css('a[href="/admin/history"]')

    expect(gestao["class"]).to include("nav-link active")
    expect(historico["class"]).not_to include("active")
  end

  it "mostra a mensagem quando não há histórico" do
    entrar_como_admin
    get global_history_path

    expect(response.body).to include("Ainda não há histórico de acessos.")
  end

  describe "GET /admin/history.pdf" do
    def texto_do_pdf
      PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join("\n")
    end

    it "baixa um PDF com os acessos" do
      criar_acesso(quando: Time.zone.today.noon)
      entrar_como_admin

      get global_history_path(format: :pdf)

      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("historico-global-")
      expect(texto_do_pdf).to include("Histórico Global de Acessos")
      expect(texto_do_pdf).to include("232012345")
    end

    it "respeita o filtro de restaurante" do
      outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
      catraca_outro = outro.turnstiles.create!(name: "T1", operation: "Ativa")
      criar_acesso(quando: Time.zone.today.noon)
      criar_acesso(quando: Time.zone.today.noon, restaurant: outro, turnstile: catraca_outro)
      entrar_como_admin

      get global_history_path(format: :pdf, restaurant_id: restaurante.id)
      texto = texto_do_pdf

      expect(texto).to include("Restaurante: #{restaurante.name}")
      expect(texto).not_to include(outro.name)
    end

    it "respeita o filtro de data" do
      outro_aluno = Account.create!(
        user: "232099999", password: "senha123", name: "Outro Estudante", role: "student"
      ).student
      antigo = criar_acesso(quando: 2.days.ago, student: outro_aluno)
      criar_acesso(quando: Time.zone.today.noon)
      entrar_como_admin

      get global_history_path(format: :pdf, date: Date.current.iso8601)
      texto = texto_do_pdf

      expect(texto).to include("Data: #{Date.current.strftime('%d/%m/%Y')}")
      expect(texto).not_to include(antigo.registration)
    end

    it "sem acessos no filtro, volta para a página com aviso" do
      criar_acesso(quando: Time.zone.today.noon)
      outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
      outro.turnstiles.create!(name: "T1", operation: "Ativa")
      entrar_como_admin

      get global_history_path(format: :pdf, restaurant_id: outro.id)

      expect(response).to redirect_to(global_history_path(restaurant_id: outro.id))
      expect(flash[:alert]).to eq("Ainda não há histórico de acessos.")
    end

    it "manda para o login quem não entrou" do
      get global_history_path(format: :pdf)
      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "filtro por data no HTML" do
    it "mostra só os acessos do dia escolhido" do
      antigo = criar_acesso(quando: 2.days.ago)
      hoje = criar_acesso(quando: Time.zone.today.noon)
      entrar_como_admin

      get global_history_path(date: Date.current.iso8601)

      expect(response.body).to include("access_#{hoje.id}")
      expect(response.body).not_to include("access_#{antigo.id}")
    end

    it "o link do PDF preserva os filtros escolhidos" do
      entrar_como_admin

      get global_history_path(restaurant_id: restaurante.id, date: Date.current.iso8601)

      esperado = global_history_path(
        format: :pdf,
        restaurant_id: restaurante.id,
        date: Date.current.iso8601
      ).gsub("&", "&amp;")

      expect(response.body).to include("href=\"#{esperado}\"")
    end
  end
end
