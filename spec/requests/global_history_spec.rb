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
end
