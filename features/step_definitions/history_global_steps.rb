Given('there is global history') do
  unless Restaurant.exists?(name: "RU Gama", campus: "Gama")
    outro = Restaurant.create!(name: "RU Gama", campus: "Gama")
    outro.turnstiles.create!(name: "T1", operation: "Ativa")
  end

  @global_accesses = []
  indice = 0

  Restaurant.includes(:turnstiles).order(:id).each do |restaurant|
    restaurant.turnstiles.each do |turnstile|
      aluno = create_student_for_access(indice)
      @global_accesses << Access.create!(
        student: aluno,
        registration: aluno.user,
        restaurant: restaurant,
        turnstile: turnstile,
        status: "allowed",
        reason: nil,
        created_at: indice.hours.ago
      )
      indice += 1
    end
  end

  visit global_history_path
end

Given('I know a turnstile of the restaurant I know') do
  @memory_know ||= {}
  @memory_know[:turnstile] = @memory_know[:restaurant].turnstiles.first
end

When('I filter by the restaurant I know') do
  restaurante = @memory_know[:restaurant]
  find('#restaurant_id').find("option[value='#{restaurante.id}']").select_option
  click_button 'Filtrar'
end

When('I filter by the turnstile I know') do
  catraca = @memory_know[:turnstile]
  find('#turnstile_id').find("option[value='#{catraca.id}']").select_option
  click_button 'Filtrar'
end

Then('I should see newest access first') do
  esperados = Access.newest_first.pluck(:id).map { |id| "access_#{id}" }
  encontrados = all('tbody tr').map { |linha| linha[:id] }
  expect(encontrados).to eq(esperados)
end

Then('I should see only the entires of the restaurant I know') do
  restaurante = @memory_know[:restaurant]
  esperados = Access.for_restaurant(restaurante.id).newest_first.pluck(:id).map { |id| "access_#{id}" }
  encontrados = all('tbody tr').map { |linha| linha[:id] }
  expect(encontrados).to match_array(esperados)
end

Then('I should see only the entires of the turnstile I know') do
  catraca = @memory_know[:turnstile]
  esperados = Access.for_turnstile(catraca.id).newest_first.pluck(:id).map { |id| "access_#{id}" }
  encontrados = all('tbody tr').map { |linha| linha[:id] }
  expect(encontrados).to match_array(esperados)
end

def create_student_for_access(indice)
  matricula = format("2320%05d", indice)
  conta = Account.create!(user: matricula, password: "senha123",
                          name: "Estudante #{indice}", role: "student")
  conta.student
end
