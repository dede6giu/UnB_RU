# guarda os valores que a tela mostra para conferir que o PDF tem os mesmos
When('I click the export PDF button') do
  @values_on_page = all('tbody tr td:last-child').map(&:text)
  click_on 'Exportar PDF'
end

When('I filter by transaction type {word}') do |type|
  find('#type').find("option[value='#{type}']").select_option
  click_button 'Filtrar'
end

Then('a PDF file for my transaction history downloads') do
  expect(page.response_headers['Content-Type']).to eq('application/pdf')
  expect(page.response_headers['Content-Disposition']).to start_with('attachment')
  @pdf_text = PDF::Reader.new(StringIO.new(page.body)).pages.map(&:text).join("\n")
  expect(@pdf_text).to include('Extrato e Histórico de Refeições')
  expect(@values_on_page).not_to be_empty
  @values_on_page.each { |value| expect(@pdf_text).to include(value) }
end

# recarga aparece com "+" e refeição com "-"; os totais do PDF não têm sinal
Then('the PDF should only contain entries for the transaction type {word}') do |type|
  case type
  when 'credit'
    expect(@pdf_text).to include('+ R$')
    expect(@pdf_text).not_to include('- R$')
  when 'meal'
    expect(@pdf_text).to include('- R$')
    expect(@pdf_text).not_to include('+ R$')
  else
    raise "Tipo sem passo ainda: #{type}"
  end
end
