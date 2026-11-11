Given('I have a turnstile') do
restaurante = Restaurant.find_or_create_by!(name: "RU", campus: "Darcy Ribeiro")
@turnstile = restaurante.turnstiles.find_or_create_by!(name: "T1") { |t| t.operation = "Ativa" }
  @turnstile = restaurante.turnstiles.create!(name: "T1", operation: "Ativa")
  visit new_access_point_path
  choose(@turnstile.name)
  click_button 'Iniciar Operação'
end

When('I click the disconnect from turnstile button') do
  click_button 'Desconectar do Ponto de Acesso'
end

When('I confirm') do
  click_button 'Confirmar'
end

Then('I should have no turnstile') do
  expect(@turnstile.reload.operator_id).to be_nil
end

When('I cancel') do
  click_on 'Cancelar'
end

Then('I should have my turnstile') do
  expect(@turnstile.reload.operator_id).to be_present
end
