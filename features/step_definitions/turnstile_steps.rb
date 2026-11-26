Dado(/^que a catraca que conheço está (.*)$/) do |mode|
  case mode
  when 'inativa'
    new_value = 'Inativa'
  when 'ativa'
    new_value = 'Ativa'
  when 'operando'
    new_value = 'Operando'
  when 'fastpass'
    new_value = 'FastPass'
  end
  @memory_know[:turnstile].update(operation: new_value)
end

Dado(/^que a catraca que conheço tem um operador associado a ela$/) do
  operator = Account.new(user: valid_value('operator_id', Account.where(role: 'operator').pluck(:user)),
                         name: valid_value('operator_name'),
                         role: 'operator',
                         password: valid_value('password'))
  operator.save
  @memory_know[:turnstile].update(operator_id: operator.id)
end

Então(/a catraca que conheço deve estar (.*)/) do |mode|
  @memory_know[:turnstile].reload
  case mode
  when 'inativa'
    new_value = 'Inativa'
  when 'ativa'
    new_value = 'Ativa'
  when 'operando'
    new_value = 'Operando'
  when 'fastpass'
    new_value = 'FastPass'
  end
  assert expect(@memory_know[:turnstile][:operation]).to eq(new_value)
end
