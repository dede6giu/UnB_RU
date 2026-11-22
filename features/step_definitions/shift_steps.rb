Given(/^I am logged in as an admin$/) do
  step "I am an admin"
end

Given(/^the (breakfast|lunch|dinner) shift goes from "(\d{2}:\d{2})" to "(\d{2}:\d{2})"$/) do |meal, starts_at, ends_at|
  Shift.find_or_initialize_by(meal_type: meal).update!(starts_at: starts_at, ends_at: ends_at)
end

When(/^I set the (breakfast|lunch|dinner) shift from "(\d{2}:\d{2})" to "(\d{2}:\d{2})"$/) do |meal, starts_at, ends_at|
  fill_in "shift-#{meal}-start", with: starts_at
  fill_in "shift-#{meal}-end", with: ends_at
end

Then(/^I should see the (breakfast|lunch|dinner) shift going from "(\d{2}:\d{2})" to "(\d{2}:\d{2})"$/) do |meal, starts_at, ends_at|
  meal_labels = { "breakfast" => "Café da manhã", "lunch" => "Almoço", "dinner" => "Janta" }
  expect(page).to have_content("#{meal_labels.fetch(meal)}: #{starts_at}–#{ends_at}")
end
