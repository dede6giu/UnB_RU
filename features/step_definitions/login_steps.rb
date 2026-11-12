Given(/^I am an? admin$/) do
  pending
end

Given(/^I am an? operator$/) do
  pending
end

Given(/^I am an? student$/) do
  pending
end

Given('there is admins') do
  @password = 'senha123'
  @conta = {
    user: '1000000',
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
  click_button 'Entrar'
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

# Matrícula com formato válido que não pertence a nenhuma conta criada nos steps acima.
When('I fill {string} unknowingly') do |string|
  matricula = string.start_with?('student-') ? '232054321' : '7654321'
  valor = string.end_with?('-user') ? matricula : 'errada99'
  fill_in string, with: valor
end

Given('there is operators') do
  @password = 'senha123'
  @conta = {
    user: '2000000',
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
  @password = 'senha123'
  @conta = {
    user: '232012345',
    password: @password,
    name: 'algum',
    role: 'student'
  }
  Account.create!(@conta)
end

Given('I know a student') do
  @conta = Account.find_by(role: 'student')
end

Then('I should see my balance') do
  pending # Depende de balance_cents
end

Then('I should see an invalid student id message') do
  expect(page).to have_content('Matrícula inválida.')
end

Given('I know all students') do
  @students = Account.where(role: 'student')
end
