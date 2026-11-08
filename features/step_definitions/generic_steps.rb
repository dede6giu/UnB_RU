require 'uri'

Given(/^there is a (.+)$/) do |model_name|
  create_models(model_name, amount=1)
end

Given(/^there are (.+)$/) do |model_name|
  create_models(model_name)
end

Given(/^there exists (.+) that are (.+)$/) do |model_name, special_situation|
  create_models(model_name, amount=100, conditions: [ special_situation ])
end

Given(/^I know a (.+)$/) do |model_name|
  @memory_know = if @memory_know == nil then {} else @memory_know end
  @memory_know[model_name.intern] = get_models(model_name)
end

Given(/^I am on the "(.+)" page$/) do |page_alias|
  visit path_to(page_alias)
end

Given(/^I am on a knowing (.+) (.+) page$/) do |model_name, page_type|
  visit model_path_to(model_name, page_type, model: @memory_know[model_name.intern])
end

Given(/^I learn another (.+)$/) do |model_name|
  @memory_another = if @memory_another == nil then {} else @memory_another end
  @memory_another[model_name.intern] = get_another(model_name, @memory_know[model_name.intern].id)
end

When(/^I fill (?:in )?"(.+)" correctly$/) do |form_label|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  fill_value = valid_value(form_label)
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

When(/^I fill (?:in )?"(.+)" incorrectly$/) do |form_label|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  fill_value = invalid_value(form_label)
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

When(/^I fill (?:in )?"(.+)" from a known (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  known_value = @memory_know[model_name.intern].send(parametrize_form_label(form_label))
  @form_fill[form_label.intern] = known_value
  fill_in form_label, with: known_value
end

When(/^I fill (?:in )?"(.+)" avoiding a known (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  known_value = @memory_know[model_name.intern].send(parametrize_form_label(form_label))
  fill_value = valid_value(form_label, avoid=[ known_value ])
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

When(/^I fill (?:in )?"(.+)" avoiding all (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  known_values = get_all_parameter_values(model_name, form_label)
  fill_value = valid_value(form_label, avoid=known_values)
  @form_fill[form_label.intern] = fill_value
  fill_in form_label, with: fill_value
end

When(/^I fill (?:in )?"(.+)" from another (.+)$/) do |form_label, model_name|
  @form_fill = if @form_fill == nil then {} else @form_fill end
  @form_fill[form_label.intern] = @memory_another[model_name.intern][form_label.intern]
  fill_in form_label, with: @memory_another[model_name.intern].send(parametrize_form_label(form_label))
end

When(/^I click (?:on )?the (.*) button$/) do |button_alias|
  click_button button_path(button_alias)
end

When(/^I click (?:on )?the (.*) link, and (.*)$/) do |button_alias, confirmation|
  click_link button_path(button_alias)
  sleep(0.2)
  case confirmation
  when "confirm"
    page.driver.browser.switch_to.alert.accept
  when "cancel"
    page.driver.browser.switch_to.alert.dismiss
  else
    raise "Unknown confirmation: #{confirmation}"
  end
end

When(/^I go to the "(.*)" page$/) do |page_alias|
  visit path_to(page_alias)
end

Then(/^I should be on (?:the )?"(.+)" page$/) do |page_alias|
  current_path = URI.parse(current_url).path
  assert_equal path_to(page_alias), current_path
end

Then(/^I should see an? (.*) message$/) do |message_alias|
  assert page.has_content?(message_kind(message_alias))
end

Then(/^I should see the new "(.+)"$/) do |form_label|
  assert page.has_content?(@form_fill[form_label.intern])
end

Then(/^I should see the (.*) I know$/) do |model_name|
  model_params = list_parameter_names(model_name)
  model_params.each do |p|
    assert page.has_content?(@memory_know[model_name.intern].send(p))
  end
end

Then(/^I should not see the (.*) I know$/) do |model_name|
  model_params = list_parameter_names(model_name)
  model_params.each do |p|
    assert expect(page).not_to have_content(@memory_know[model_name.intern].send(p))
  end
end
