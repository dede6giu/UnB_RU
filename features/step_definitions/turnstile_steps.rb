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
  operator = Account.new(user: valid_value('operator_id', Account.where(role: 'operator').pluck(:user)),
                         name: valid_value('operator_name'),
                         role: 'operator',
                         password: valid_value('password'))
  operator.save
  @memory_know[:turnstile].update(operator_id: operator.id)
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
