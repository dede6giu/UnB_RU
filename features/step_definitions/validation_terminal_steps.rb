Quando(/^valido a matrícula de um estudante (com|sem) saldo suficiente$/) do |saldo|
  @student_checked = saldo == "com" ? @student_with_balance : @student_without_balance
  @balance_before_check = @student_checked.balance_cents
  fill_in "registration", with: @student_checked.user
  click_button "Validar"
end

Quando('valido uma matrícula não cadastrada') do
  fill_in "registration", with: "232054321"
  click_button "Validar"
end
