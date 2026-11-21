When(/^I validate the registration of a student (with|without) enough balance$/) do |saldo|
  @student_checked = saldo == "with" ? @student_with_balance : @student_without_balance
  @balance_before_check = @student_checked.balance_cents
  fill_in "registration", with: @student_checked.user
  click_button "Validar"
end

When(/^I validate an unregistered registration$/) do
  fill_in "registration", with: "232054321"
  click_button "Validar"
end
