Given('there is admins') do
  @password = '123456'
  @conta = {
    user: '000000000',
    password: @password,
    name: 'algum',
    role: 'admin'
  }
  Account.create!(@conta)
end

Given('I am on the {string} page') do |string|
  visit path_to(string)
end

Given('I know an admin') do
  @conta = Account.find_by(role: 'admin')
end

When('I fill {string} knowingly') do |string|
  valor = string.end_with?('-user') ? @conta[:user] : @password
  fill_in string, with: valor
end

When('I click on the login button') do
  click_button 'Login'
end

Then('I should be authenticated') do
  expect(page).to have_content('Sucesso na autenticação.')
end

Then('I should be on the {string} page') do |string|
  expect(page).to have_title(string)
end

When('I fill {string} incorrectly') do |string|
  valor = string.end_with?('-user') ? '0000000015' : '000000'
  fill_in string, with: valor
end

When('I fill {string} correctly') do |string|
  valor = string.end_with?('-user') ? @conta[:user] : @password
  fill_in string, with: valor
end

Then('I should see an invalid admin id message') do
  expect(page).to have_content('Matrícula inválida.')
end

Then('I should see an incorrect credentials message') do
  expect(page).to have_content('Matrícula ou senha incorretas.')
end

Given('I know all admins') do
  @admins = Account.where(role: 'admin')
end

When('I fill {string} unknowingly') do |string|
  valor = string.end_with?('-user') ? '232022674' : '987654'
  fill_in string, with: valor
end

Given('there is operators') do
  @password = '123456'
  @conta = {
    user: '111111111',
    password: @password,
    name: 'algum',
    role: 'operator'
  }
  Account.create!(@conta)
end

Given('I know an operator') do
  @conta = Account.find_by(role: 'operator')
end

Then('I should see an invalid operator id message') do
  expect(page).to have_content('Matrícula inválida.')
end

Given('I know all operators') do
  @operators = Account.where(role: 'operator')
end

Given('there is students') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('I know a student') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I should see my balance') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I should see an invalid student id message') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('I know all students') do
  pending # Write code here that turns the phrase above into concrete actions
end