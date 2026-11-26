WALLET_BALANCE_CENTS = 1800

Dado('que sou um estudante') do
  @password = 'senha123'
  conta = Account.create!(user: '232012345', password: @password, name: 'Estudante', role: 'student')
  @student = conta.student

  visit new_student_session_path
  fill_in 'student-user', with: conta.user
  fill_in 'student-pass', with: @password
  click_button 'Entrar'
  expect(page).to have_content('Sucesso na autenticação.')
end

Dado('que tenho saldo') do
  @student.update!(balance_cents: WALLET_BALANCE_CENTS)
end

Quando('escolho a opção de recarga PIX') do
  choose 'PIX Instantâneo'
end

Quando('escolho a opção de recarga cartão de crédito') do
  choose 'Cartão de Crédito'
end

# depois da recarga o estudante continua na página de recarga, então o passo abre o extrato
# 5 refeições de R$ 4,50
Então('devo ver a nova recarga por PIX no extrato') do
  visit path_to('Extrato e Histórico de Refeições')
  within('tbody') do
    expect(page).to have_content('Recarga de Saldo')
    expect(page).to have_content('PIX')
    expect(page).to have_content('+ R$ 22,50')
  end
end

Então('devo ver a nova recarga por cartão de crédito no extrato') do
  visit path_to('Extrato e Histórico de Refeições')
  within('tbody') do
    expect(page).to have_content('Recarga de Saldo')
    expect(page).to have_content('Cartão de Crédito')
    expect(page).to have_content('+ R$ 22,50')
  end
end

# R$ 18,00 que já tinha + R$ 22,50 da recarga
Então('devo ver meu saldo aumentado com o valor da recarga') do
  expect(page).to have_content('R$ 40,50')
  expect(@student.reload.balance_cents).to eq(WALLET_BALANCE_CENTS + 2250)
end

Então('devo ver meu saldo sem alteração') do
  expect(page).to have_content('R$ 18,00')
  expect(@student.reload.balance_cents).to eq(WALLET_BALANCE_CENTS)
end
