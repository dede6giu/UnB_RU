Then(/^I should see the new restaurant$/) do
  value_name = @form_fill[:restaurant_name]
  value_campus = @form_fill[:restaurant_campus]
  assert page.has_content?(value_name) and
    page.has_content?(value_campus) and
    Restaurant.all.where(name: value_name, campus: value_campus).empty?
end

Then(/^operators should see the restaurant's new "(.+)" on the "Configuração de Ponto" page$/) do |form_label|
  pending
end