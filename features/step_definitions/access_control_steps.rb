require 'rspec/expectations'

Given('I am the application') do
  @app = :application
end

Given('there are students with enough balance') do
  @student_with_balance = { 
    name: "Alice", 
    balance: 10.0, 
    meal_cost: 4.50 
  }
end

Given('there are students without enough balance') do
  @student_without_balance = { 
    name: "Bob", 
    balance: 2.0, 
    meal_cost: 4.50 
  }
end

When('I check a student with enough balance') do

  student = @student_with_balance
  if student[:balance] >= student[:meal_cost]
    student[:balance] -= student[:meal_cost]
    @message = :allow
  else
    @message = :block
  end
end

Then('I should send an allow student message') do
  expect(@message).to eq(:allow)
end

Then('the student balance should be a meal lower') do
  expected_balance = 10.0 - 4.50
  expect(@student_with_balance[:balance]).to eq(expected_balance)
end

When('I check a student without enough balance') do
  student = @student_without_balance
  if student[:balance] >= student[:meal_cost]
    student[:balance] -= student[:meal_cost]
    @message = :allow
  else
    @message = :block
  end
end

Then('I should send a block student message') do
  expect(@message).to eq(:block)
end

When('I check an unregistered student') do
  @message = :unregistered
end

Then('I should send an unregistered student message') do
  expect(@message).to eq(:unregistered)
end
