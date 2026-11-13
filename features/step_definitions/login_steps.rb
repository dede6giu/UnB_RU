Given(/^I am an? admin$/) do
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

Given('I know an admin') do
  @conta = Account.find_by(role: 'admin')
end

When('I fill {string} knowingly') do |string|
  valor = string =~ /[-_]user$/ ? @conta[:user] : @password
  fill_in string, with: valor
end

Then('I should be authenticated') do
  expect(page).to have_content('Sucesso na autenticação.')
end

Then('I should be newly registered') do
  sleep(1)
  expect(page).to have_content('Sucesso no cadastro.')
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
  @balance = 1550
  Account.create!(@conta)
  Account.find(@conta[:user]).student.update!(balance_cents: @balance)
end

Given('I know a student') do
  @conta = Account.where(role: 'student').first
end

Then('I should see my balance') do
  expect(page).to have_content("Saldo: R$ 15,50")
end

Given('I know all students') do
  @students = Account.where(role: 'student')
end
