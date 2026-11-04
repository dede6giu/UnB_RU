require 'uri'

Given(/^I am on the "(.+)" page$/) do |page_alias|
  visit path_to(page_alias)
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

When(/^I click (?:on )?the (.*) button$/) do |button_alias|
  click_button button_path(button_alias)
end

Then(/^I should be on (?:the )?"(.+)" page$/) do |page_alias|
  current_path = URI.parse(current_url).path
  assert_equal path_to(page_alias), current_path
end

Then(/^I should see an? (.*) message$/) do |message_alias|
  pending
end