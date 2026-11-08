Then(/^I should see the new restaurant$/) do
  value_name = @form_fill[:restaurant_name]
  value_campus = @form_fill[:restaurant_campus]
  assert page.has_content?(value_name) and
    page.has_content?(value_campus) and
    Restaurant.all.where(name: value_name, campus: value_campus).empty?
end

Then(/^operators should see the restaurant's new "(.+)" on the "Configuração de Ponto" page$/) do |form_label|
  next
end

Given(/^the restaurant I know has a (.*) turnstile$/) do |status|
  r_id = @memory_know[:restaurant].id
  Turnstile.create!(name: valid_value("turnstile_name"),
                    operation: want_mapping(status)[:operation].sample,
                    restaurant_id: r_id)
end
