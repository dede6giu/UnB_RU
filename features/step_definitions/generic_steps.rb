def internal_name(model_name)
  case model_name
  when "restaurante"
    :restaurant
  when "catraca"
    :turnstile
  end
end

Dado(/^(?:que )?existe uma? (restaurante|catraca)$/) do |model_name|
  create_models(model_name, amount=1)
end

Dado(/^(?:que )?existem (restaurantes|catracas)$/) do |model_name|
  create_models(model_name)
end

Dado(/^(?:que )?existem (.+) que (?:são|estão) (.+)$/) do |model_name, special_situation|
  create_models(model_name, amount=100, conditions: [ special_situation ])
end

Dado(/^(?:que )?(?:eu )?conheço uma? (restaurante|catraca)$/) do |model_name|
  @memory_know = if @memory_know == nil then {} else @memory_know end
  @memory_know[internal_name(model_name)] = get_models(model_name)
end

Dado(/^(?:que )?(?:eu )?estou na página "(.+)"$/) do |page_alias|
  visit path_to(page_alias)
end

Dado(/^(?:que )?(?:eu )?estou na página d[eoa] (.+) d[eoa] (.+) que conheço$/) do |page_type, model_name|
  visit model_path_to(model_name, page_type, model: @memory_know[internal_name(model_name)])
end

Dado(/^(?:que )?(?:eu )?aprendo outr[ao] (.+)$/) do |model_name|
  @memory_another = if @memory_another == nil then {} else @memory_another end
  @memory_another[internal_name(model_name)] = get_another(model_name, @memory_know[internal_name(model_name)].id)
end

Quando(/^do dropdown "(.*)" (?:eu )?escolho qualquer coisa$/) do |form_label|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  if form_label == "turnstile_restaurant_id"
    restaurant = Restaurant.order("RANDOM()").first
    fill_value = "#{restaurant.campus} - #{restaurant.name}"
  else
    fill_value = valid_value(form_label)
  end
  @form_fill[form_label.intern] = fill_value
  select fill_value, from: form_label
end

Quando(/^do dropdown "(.*)" (?:eu )?escolho "(.*)"$/) do |form_label, fill_value|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  @form_fill[form_label.intern] = fill_value
  select fill_value, from: form_label
end

Quando(/^(?:eu )?preencho "(.+)" corretamente$/) do |form_label|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  fill_value = valid_value(form_label)
  @form_fill[form_label.intern] = fill_value
  preencher form_label, fill_value
end

Quando(/^(?:eu )?preencho "(.+)" incorretamente$/) do |form_label|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  fill_value = invalid_value(form_label)
  @form_fill[form_label.intern] = fill_value
  preencher form_label, fill_value
end

Quando(/^(?:eu )?preencho "(.+)" com o valor d[eoa] (.+) que conheço$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  known_value = @memory_know[internal_name(model_name)].send(parametrize_form_label(form_label))
  @form_fill[form_label.intern] = known_value
  fill_in form_label, with: known_value
end

Quando(/^do dropdown "(.*)" (?:eu )?escolho o valor d[oa] (.*) que conheço$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  if form_label == "turnstile_restaurant_id"
    restaurant = Restaurant.where(id: @memory_know[internal_name(model_name)].restaurant_id).first
    known_value = "#{restaurant.campus} - #{restaurant.name}"
  else
    known_value = @memory_know[internal_name(model_name)].send(parametrize_form_label(form_label))
  end
  @form_fill[form_label.intern] = known_value
  select known_value, from: form_label
end

When(/^I fill (?:in )?"(.+)" avoiding a known (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  fill_value = valid_value(form_label, avoid=[ known_value ])
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

Quando(/^(?:eu )?preencho "(.+)" evitando tod[oa]s (?:[oa]s )?(.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  known_values = get_all_parameter_values(model_name, form_label)
  fill_value = valid_value(form_label, avoid=known_values)
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

Quando(/^(?:eu )?preencho "(.+)" com o valor d[aeo] outr[oa] (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  @form_fill[form_label.intern] = @memory_another[internal_name(model_name)][form_label.intern]
  fill_in form_label, with: @memory_another[internal_name(model_name)].send(parametrize_form_label(form_label))
end

Quando(/^do dropdown "(.*)" (?:eu )?escolho o valor d[eoa] outr[oa] (.*)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  if form_label == "turnstile_restaurant_id"
    restaurant = Restaurant.where(id: @memory_another[internal_name(model_name)].restaurant_id).first
    fill_value = "#{restaurant.campus} - #{restaurant.name}"
  else
    fill_value = @memory_another[internal_name(model_name)].send(parametrize_form_label(form_label))
  end
  @form_fill[form_label.intern] = fill_value
  select fill_value, from: form_label
end

Quando(/^(?:eu )?clico no botão (?:d[eao] )?(.*)$/) do |button_alias|
  click_on button_path(button_alias)
end

Quando(/(?:eu )?clicar no link (?:d[eoa] )?(.*), e (.*)$/) do |button_alias, confirmation|
  click_link button_path(button_alias)
  sleep(0.2)
  case confirmation
  when "confirmar"
    page.driver.browser.switch_to.alert.accept
  when "cancelar"
    page.driver.browser.switch_to.alert.dismiss
  else
    raise "Unknown confirmation: #{confirmation}"
  end
end

Quando(/^(?:eu )?vou para a página (?:d[eao] )?"(.*)"$/) do |page_alias|
  visit path_to(page_alias)
end

Então(/^(?:eu )?devo estar na página (?:d[eoa] )?"(.+)"$/) do |page_alias|
  expect(page).to have_title(page_alias)
end

Então(/^(?:eu )?devo ver uma mensagem (?:d[eao] )?(.*)$/) do |message_alias|
  # sleep(0.5)
  # expect(page).to have_content(message_kind(message_alias))
  assert page.has_content?(message_kind(message_alias))
end

Então(/^(?:eu )?devo ver [oa] nov[oa] "(.+)"$/) do |form_label|
  assert page.has_content?(@form_fill[form_label.intern])
end

Então(/^(?:eu )?devo ver [oa] (.*) que conheço$/) do |model_name|
  model_params = list_parameter_names(model_name)
  model_params.each do |p|
    assert page.has_content?(@memory_know[internal_name(model_name)].send(p))
  end
end

Então(/^(?:eu )?não devo ver [oa] (.*) que conheço$/) do |model_name|
  begin
    find_by_id("#{model_name}_#{@memory_know[internal_name(model_name)].id}")
    fail
  rescue Capybara::ElementNotFound
    next
  end
  # model_params = list_parameter_names(model_name)
  # model_params.each do |p|
  #   assert expect(page).not_to have_content(@memory_know[internal_name(model_name)].send(p))
  # end
end
