ACCESS_CONTROL_STUDENT_BALANCE_CENTS = 1000
MEAL_COST_CENTS = 450

Given('I am the application') do
  nil
end

Given('there are students with enough balance') do
  conta = Account.create!(user: '232065432', password: 'senha123', name: 'Estudante', role: 'student')
  @student_with_balance = conta.student
  @student_with_balance.update!(balance_cents: ACCESS_CONTROL_STUDENT_BALANCE_CENTS)
end

Given('there are students without enough balance') do
  conta = Account.create!(user: '232076543', password: 'senha123', name: 'Estudante', role: 'student')
  @student_without_balance = conta.student
end

When('I check a student with enough balance') do
  @student_checked = @student_with_balance
  @balance_before_check = @student_checked.balance_cents
  page.driver.browser.post('/access_control/check', registration: @student_checked.id)
end

Then('I should send an allow student message') do
  resposta = page.driver.browser.last_response
  expect(resposta.status).to eq(200)
  expect(JSON.parse(resposta.body)['message']).to eq('Acesso Liberado')
end

Then("the student's balance should be a meal lower") do
  expect(@student_checked.reload.balance_cents).to eq(@balance_before_check - MEAL_COST_CENTS)
end

Then("the student's statement should show a meal entry") do
  lancamento = @student_checked.transactions.debits.last
  expect(lancamento).to be_present
  expect(lancamento.amount_cents).to eq(MEAL_COST_CENTS)
end

When('I check a student without enough balance') do
  @student_checked = @student_without_balance
  @balance_before_check = @student_checked.balance_cents
  page.driver.browser.post('/access_control/check', registration: @student_checked.id)
end

Then('I should send a block student message') do
  resposta = page.driver.browser.last_response
  expect(resposta.status).to eq(403)
  expect(JSON.parse(resposta.body)['message']).to eq('Saldo Insuficiente')
end

Then("the student's balance should be unchanged") do
  expect(@student_checked.reload.balance_cents).to eq(@balance_before_check)
end

Then("the student's statement should show no entries") do
  expect(@student_checked.transactions.count).to eq(0)
end

When('I check an unregistered student') do
  page.driver.browser.post('/access_control/check', registration: '232054321')
end

Then('I should send an unregistered student message') do
  resposta = page.driver.browser.last_response
  expect(resposta.status).to eq(404)
  expect(JSON.parse(resposta.body)['message']).to eq('Estudante Não Cadastrado')
end
