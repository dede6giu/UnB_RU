# Cria (ou reutiliza) um restaurante com catraca e registra acessos nele.
# Retorna o restaurante; não altera a feature nem o código de produção.
def restaurant_with_accesses(name, quantidade: 1)
  restaurante = Restaurant.find_or_create_by!(name: name) do |r|
    r.campus = "Campus #{name}"
  end
  restaurante.turnstiles.create!(name: "T1", operation: "Ativa") if restaurante.turnstiles.empty?
  catraca = restaurante.turnstiles.first

  quantidade.times do |indice|
    aluno = student_for_export
    Access.create!(
      student: aluno,
      registration: aluno.user,
      restaurant: restaurante,
      turnstile: catraca,
      status: "allowed",
      reason: nil,
      created_at: indice.minutes.ago
    )
  end

  restaurante
end

# Cria um estudante com matrícula única para o cenário.
# Retorna o Student; usa o contador do cenário para não colidir com outros steps.
def student_for_export
  @export_student_number = (@export_student_number || 0) + 1
  matricula = format("2310%05d", @export_student_number)
  conta = Account.create!(user: matricula, password: "senha123",
                          name: "Estudante #{@export_student_number}", role: "student")
  conta.student
end

Given('there is access history in the restaurants {string} and {string}') do |filtrado, nao_filtrado|
  restaurant_with_accesses(filtrado)
  restaurant_with_accesses(nao_filtrado)
  visit global_history_path
end

Given('there is access history in the restaurant {string}') do |nome|
  restaurant_with_accesses(nome)
  visit global_history_path
end

Given('there is global history today') do
  restaurante = Restaurant.order(:id).last
  catraca = restaurante.turnstiles.first
  aluno = student_for_export

  Access.create!(
    student: aluno,
    registration: aluno.user,
    restaurant: restaurante,
    turnstile: catraca,
    status: "allowed",
    reason: nil,
    created_at: Time.zone.today.noon
  )

  visit global_history_path
end

When('I filter by restaurant {string}') do |nome|
  restaurante = Restaurant.find_or_create_by!(name: nome) do |r|
    r.campus = "Campus #{nome}"
  end

  # No cenário sem resultados, o restaurante pode ter sido criado agora,
  # depois que a página já estava carregada. Recarregue para a opção existir.
  opcao = "#{restaurante.campus} - #{restaurante.name}"
  visit global_history_path unless page.has_select?("restaurant_id", with_options: [ opcao ])

  select opcao, from: "restaurant_id"
  click_button "Filtrar"
end

When('I filter by today') do
  fill_in "date", with: Date.current.iso8601
  click_button "Filtrar"
end

Then('a PDF file for the global history downloads') do
  expect(page.response_headers["Content-Type"]).to eq("application/pdf")
  expect(page.response_headers["Content-Disposition"]).to include("historico-global")

  @pdf_text = PDF::Reader.new(StringIO.new(page.body)).pages.map(&:text).join("\n")
  expect(@pdf_text).to include("Histórico Global de Acessos")
end

Then('the PDF should only contain entries for the restaurant {string}') do |nome|
  expect(@pdf_text).to include(nome)

  Restaurant.where.not(name: nome).pluck(:name).each do |outro|
    expect(@pdf_text).not_to include(outro)
  end
end

Then('the PDF should show the filter by date today') do
  expect(@pdf_text).to include("Data: #{Date.current.strftime('%d/%m/%Y')}")
end
