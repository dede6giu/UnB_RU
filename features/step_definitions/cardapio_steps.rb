require "active_support/testing/time_helpers"

World(ActiveSupport::Testing::TimeHelpers)

Before do
  @cardapio_time_travelled = false
end

After do
  travel_back if @cardapio_time_travelled
end

Given(/^(?:today|it) is (\w+) during (breakfast|lunch|dinner) time$/) do |weekday, meal|
  hour, minute = { "breakfast" => [ 8, 0 ], "lunch" => [ 12, 0 ], "dinner" => [ 18, 0 ] }.fetch(meal)
  set_cardapio_time(weekday, hour, minute)
end

Given(/^it is (\w+) (before breakfast time|after breakfast time and before lunch time|after lunch time and before dinner time|after dinner time)$/) do |weekday, moment|
  hour, minute = {
    "before breakfast time" => [ 6, 0 ],
    "after breakfast time and before lunch time" => [ 10, 0 ],
    "after lunch time and before dinner time" => [ 15, 0 ],
    "after dinner time" => [ 20, 0 ]
  }.fetch(moment)
  set_cardapio_time(weekday, hour, minute)
end

Then(/^I should see the (breakfast|lunch|dinner) menu for (\w+)$/) do |meal, weekday|
  expected_weekday = portuguese_weekday(weekday)
  expected_meal = {
    "breakfast" => "Café da Manhã",
    "lunch" => "Almoço",
    "dinner" => "Janta"
  }.fetch(meal)

  if page.has_css?("#selected-menus")
    expect(page).to have_css("#selected-day", text: expected_weekday)
    within("#selected-menus") do
      expect(page).to have_css("h3", text: expected_meal)
    end
  elsif page.has_css?("#meal-widget")
    within("#meal-widget") do
      expect(page).to have_css("h2", text: expected_meal)
      expect(page).to have_content(expected_weekday)
    end
  else
    raise "The page does not contain a public menu or a meal widget."
  end
end

When(/^I choose (\w+) from "(.+)"$/) do |weekday, field_id|
  weekday_index = Date::DAYNAMES.index(weekday)
  raise ArgumentError, "Unknown weekday: #{weekday}" unless weekday_index

  select MenuCatalog::WEEKDAYS.fetch(weekday_index).last, from: field_id
  click_button "Ver cardápios" if field_id == "cardapio-weekday"
end

Then(/^I should see all menus for (\w+)$/) do |weekday|
  expect(page).to have_css("#selected-day", text: portuguese_weekday(weekday))
  within("#selected-menus") do
    MenuCatalog::MEALS.each do |_meal_key, label|
      expect(page).to have_css("h3", text: label)
    end
  end
end

Then(/^I should see a no current meal message$/) do
  set_cardapio_time(Date::DAYNAMES[Date.current.wday], 10, 0) unless @cardapio_time_travelled
  expect(page).to have_css("#no-current-meal", text: /Não há uma refeição sendo servida neste momento/)
end

def set_cardapio_time(weekday, hour, minute)
  weekday_index = Date::DAYNAMES.index(weekday)
  raise ArgumentError, "Unknown weekday: #{weekday}" unless weekday_index

  date = Date.current + ((weekday_index - Date.current.wday) % 7)
  travel_to(Time.zone.local(date.year, date.month, date.day, hour, minute))
  @cardapio_time_travelled = true
  visit current_path
end

def portuguese_weekday(weekday)
  weekday_index = Date::DAYNAMES.index(weekday)
  raise ArgumentError, "Unknown weekday: #{weekday}" unless weekday_index

  MenuCatalog::WEEKDAYS.fetch(weekday_index).last
end
