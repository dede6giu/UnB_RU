Quando('filtro pelo tipo de lançamento {string}') do |tipo|
  select tipo, from: 'type'
  click_button 'Filtrar'
  @values_on_page = all('tbody tr td:last-child').map(&:text)
end

Então('um PDF com o meu extrato é baixado') do
  expect(page.response_headers['Content-Type']).to eq('application/pdf')
  expect(page.response_headers['Content-Disposition']).to start_with('attachment')
  @pdf_text = PDF::Reader.new(StringIO.new(page.body)).pages.map(&:text).join("\n")
  expect(@pdf_text).to include('Extrato e Histórico de Refeições')
  expect(@values_on_page).not_to be_empty
  @values_on_page.each { |value| expect(@pdf_text).to include(value) }
end

# recarga aparece com "+" e refeição com "-"; os totais do PDF não têm sinal
Então('o PDF só deve ter lançamentos do tipo {string}') do |tipo|
  case tipo
  when 'Recargas'
    expect(@pdf_text).to include('+ R$')
    expect(@pdf_text).not_to include('- R$')
  when 'Refeições'
    expect(@pdf_text).to include('- R$')
    expect(@pdf_text).not_to include('+ R$')
  when 'Café da manhã', 'Almoço', 'Jantar'
    expect(@pdf_text).to include(tipo)
    outras = [ 'Café da manhã', 'Almoço', 'Jantar' ] - [ tipo ]
    outras.each { |outra| expect(@pdf_text).not_to include(outra) }
    expect(@pdf_text).not_to include('+ R$')
  else
    raise "Tipo sem passo ainda: #{tipo}"
  end
end
