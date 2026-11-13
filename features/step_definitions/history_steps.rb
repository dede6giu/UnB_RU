HISTORY_ENTRIES = [
  { kind: 'credit', payment_method: 'pix', amount_cents: 4500, ago: 2.days, text: '+ R$ 45,00' },
  { kind: 'debit', payment_method: nil, amount_cents: 450, ago: 1.day, text: '- R$ 4,50' },
  { kind: 'credit', payment_method: 'credit_card', amount_cents: 900, ago: 1.hour, text: '+ R$ 9,00' }
].freeze

Given('I have transaction history') do
  HISTORY_ENTRIES.each do |entry|
    Transaction.create!(student: @student, kind: entry[:kind], payment_method: entry[:payment_method],
                        amount_cents: entry[:amount_cents], created_at: entry[:ago].ago)
  end
  visit path_to('Extrato e Histórico de Refeições')
end

Then('I should see newest entry first') do
  newest_first = HISTORY_ENTRIES.reverse.map { |entry| entry[:text] }
  within('tbody') do
    rows = all('tr').map(&:text)
    expect(rows.size).to eq(newest_first.size)
    rows.zip(newest_first).each { |row, text| expect(row).to include(text) }
  end
end
