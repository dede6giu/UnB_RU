# Valores dos campos da recarga para "I fill ... correctly/incorrectly".
# "credit-amount" é a quantidade de refeições ("Outra quantidade" da tela).
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

# Também usado por outras features (cardapio_widget, history_student, ...).
Given('I am a student') do
  @password = 'senha123'
  conta = Account.find_by(user: '232012345') ||
          Account.create!(user: '232012345', password: @password, name: 'Estudante', role: 'student')
  Student.find_or_create_by!(account: conta)

  visit new_student_session_path
  fill_in 'student-user', with: conta.user
  fill_in 'student-pass', with: @password
  click_button 'Entrar'
end

Given('I have balance') do
  Student.last.update!(balance_cents: WALLET_BALANCE_CENTS)
  @balance_before = WALLET_BALANCE_CENTS
end

When(/^I choose (?:the )?PIX credit option$/) do
  choose 'PIX Instantâneo'
end

When(/^I choose (?:the )?Credit Card credit option$/) do
  choose 'Cartão de Crédito'
end

When('I click on the confirm transaction button') do
  click_button 'Confirmar'
end

Then('I should see the new PIX extract entry') do
  expect(page).to have_css('tbody tr', text: /Recarga de Saldo.*PIX/m)
end

Then('I should see the new Credit Card extract entry') do
  expect(page).to have_css('tbody tr', text: /Recarga de Saldo.*Cartão de Crédito/m)
end

Then('I should see my balance increased by the added amount') do
  added = WALLET_CORRECT_VALUES['credit-amount'].to_i * RechargesController::MEAL_PRICE_CENTS
  expected = @balance_before + added
  expect(Student.last.balance_cents).to eq(expected)
  expect(page).to have_content("Saldo atual: #{ApplicationController.helpers.reais(expected)}")
end

Then('I should see a incorrect credit amount message') do
  expect(page).to have_content('Quantidade inválida.')
end

Then('I should see an invalid credit amount message') do
  expect(page).to have_content('Quantidade inválida.')
end

Then('I should see an invalid Credit Card info message') do
  expect(page).to have_content('Dados do cartão inválidos.')
end

Then('I should see my balance had no change') do
  expect(Student.last.balance_cents).to eq(@balance_before)
  expect(page).to have_content(ApplicationController.helpers.reais(@balance_before))
end
