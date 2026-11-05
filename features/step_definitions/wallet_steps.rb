WALLET_CORRECT_VALUES = {
  'credit-amount' => '5',
  'card-number' => '4111111111111111',
  'card-expire' => '12/99',
  'card-secure' => '123'
}.freeze

WALLET_INCORRECT_VALUES = {
  'credit-amount' => 'abc',
  'card-number' => '4111',
  'card-expire' => '01/20',
  'card-secure' => '12'
}.freeze

WALLET_BALANCE_CENTS = 1800

Given('I am a student') do
  @password = 'senha123'
  conta = Account.create!(user: '232012345', password: @password, name: 'Estudante', role: 'student')
  @student = conta.student

  visit new_student_session_path
  fill_in 'student-user', with: conta.user
  fill_in 'student-pass', with: @password
  click_button 'Entrar'
  expect(page).to have_content('Sucesso na autenticação.')
end

Given('I have balance') do
  @student.update!(balance_cents: WALLET_BALANCE_CENTS)
end

When('I choose PIX credit option') do
  choose 'PIX Instantâneo'
end

When('I choose (the )Credit Card credit option') do
  choose 'Cartão de Crédito'
end

When('I click on the confirm transaction button') do
  click_button 'Confirmar'
end

# 5 refeições de R$ 4,50
Then('I should see the new PIX extract entry') do
  within('tbody') do
    expect(page).to have_content('Recarga de Saldo')
    expect(page).to have_content('PIX')
    expect(page).to have_content('+ R$ 22,50')
  end
end

Then('I should see the new Credit Card extract entry') do
  within('tbody') do
    expect(page).to have_content('Recarga de Saldo')
    expect(page).to have_content('Cartão de Crédito')
    expect(page).to have_content('+ R$ 22,50')
  end
end

# R$ 18,00 que já tinha + R$ 22,50 da recarga
Then('I should see my balance increased by the added amount') do
  expect(page).to have_content('Saldo atual: R$ 40,50')
end

Then('I should see an invalid credit amount message') do
  expect(page).to have_content('Quantidade inválida.')
end

Then('I should see an invalid Credit Card info message') do
  expect(page).to have_content('Dados do cartão inválidos.')
end

Then('I should see my balance had no change') do
  expect(page).to have_content('R$ 18,00')
  expect(@student.reload.balance_cents).to eq(WALLET_BALANCE_CENTS)
end
