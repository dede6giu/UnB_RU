HISTORY_ENTRIES = [
  { kind: 'credit', payment_method: 'pix', amount_cents: 4500, ago: 3.days, text: '+ R$ 45,00' },
  { kind: 'debit', meal: 'breakfast', amount_cents: 450, ago: 2.days, text: '- R$ 4,50' },
  { kind: 'debit', meal: 'lunch', amount_cents: 450, ago: 1.day, text: '- R$ 4,50' },
  { kind: 'debit', meal: 'dinner', amount_cents: 450, ago: 5.hours, text: '- R$ 4,50' },
  { kind: 'credit', payment_method: 'credit_card', amount_cents: 900, ago: 1.hour, text: '+ R$ 9,00' }
].freeze

SHIFT_HOURS = { 'breakfast' => %w[07:00 09:00], 'lunch' => %w[11:00 14:00], 'dinner' => %w[17:00 19:30] }.freeze

# a refeição sabe qual foi pelo turno gravado no acesso que gerou o débito
def meal_access(turnstile, meal)
  starts_at, ends_at = SHIFT_HOURS[meal]
  shift = Shift.find_or_create_by!(meal_type: meal) do |novo|
    novo.starts_at = starts_at
    novo.ends_at = ends_at
  end
  Access.create!(student: @student, registration: @student.user, restaurant: turnstile.restaurant,
                 turnstile: turnstile, shift: shift, status: 'allowed')
end

Given('I have transaction history') do
  turnstile = Restaurant.create!(name: 'RU Darcy', campus: 'Darcy Ribeiro').turnstiles.create!(name: 'Catraca 1', operation: 'Ativa')
  HISTORY_ENTRIES.each do |entry|
    access = meal_access(turnstile, entry[:meal]) if entry[:meal]
    Transaction.create!(student: @student, kind: entry[:kind], payment_method: entry[:payment_method],
                        amount_cents: entry[:amount_cents], access: access, created_at: entry[:ago].ago)
  end
  visit path_to('Extrato e Histórico de Refeições')
  # o passo do PDF confere que ele tem os mesmos valores da tela
  @values_on_page = all('tbody tr td:last-child').map(&:text)
end

Then('I should see newest entry first') do
  newest_first = HISTORY_ENTRIES.reverse.map { |entry| entry[:text] }
  within('tbody') do
    rows = all('tr').map(&:text)
    expect(rows.size).to eq(newest_first.size)
    rows.zip(newest_first).each { |row, text| expect(row).to include(text) }
  end
end
