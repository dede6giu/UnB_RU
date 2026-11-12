Given('there are restaurants with turnstiles') do
  restaurante = Restaurant.create!(name: "RU", campus: "Darcy Ribeiro")

  restaurante.turnstiles.create!(name: "T1", operation: "Ativa")
  restaurante.turnstiles.create!(name: "T2", operation: "Inativa")
  restaurante.turnstiles.create!(name: "T3", operation: "Operando")
end

Given('I am an operator') do
  @password = 'senha123'
  @conta = {
    user: '2000000',
    password: @password,
    name: 'algum',
    role: 'operator'
  }
  Account.create!(@conta)
  expect(path_to('Autenticação do Operador')).to eq(new_operator_session_path)
  visit new_operator_session_path
  fill_in 'operator-user', with: @conta[:user]
  fill_in 'operator-pass', with: @conta[:password]
  click_button 'Entrar'
  expect(page).to have_content('Sucesso na autenticação.')
end

Given('I know an active turnstile') do
  @turnstiles = Turnstile.find_by(operation: 'Ativa')
end

When('I choose a turnstile knowingly') do
  choose(@turnstiles.name)
end

When('I press the start operation button') do
  click_button 'Iniciar Operação'
end

Then('I should see my turnstile') do
  expect(page).to have_content(@turnstiles.name)
end

Then('I should see the choose a turnstile message') do
  expect(page).to have_content('Escolha um ponto de acesso para iniciar a operação.')
end

Given('I know an inactive turnstile') do
  @turnstiles = Turnstile.find_by(operation: 'Inativa')
end

Then('I should see the inactive turnstile message') do
  expect(page).to have_content('O ponto de acesso escolhido está inativo.')
end

Given('I know an operating turnstile') do
  @turnstiles = Turnstile.find_by(operation: 'Operando')
end

Then('I should see the already operating turnstile message') do
  expect(page).to have_content('O ponto de acesso escolhido já está em operação.')
end
