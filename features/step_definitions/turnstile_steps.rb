Given(/^the turnstile I know is (.*)$/) do |mode|
  case mode
  when 'inactive'
    new_value = 'Inativa'
  when 'active'
    new_value = 'Ativa'
  when 'operating'
    new_value = 'Operando'
  when 'fastpass'
    new_value = 'FastPass'
  end
  @memory_know[:turnstile].update(operation: new_value)
end

Given(/^the turnstile I know has an operator associated to it$/) do
  pending
end

Then(/the turnstile I know should be (.*)/) do |mode|
  @memory_know[:turnstile].reload
  case mode
  when 'inactive'
    new_value = 'Inativa'
  when 'active'
    new_value = 'Ativa'
  when 'operating'
    new_value = 'Operando'
  when 'fastpass'
    new_value = 'FastPass'
  end
  assert expect(@memory_know[:turnstile][:operation]).to eq(new_value)
end
