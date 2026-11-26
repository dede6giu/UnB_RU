require "active_support/testing/time_helpers"

World(ActiveSupport::Testing::TimeHelpers)

Before do
  @cardapio_time_travelled = false
end

After do
  travel_back if @cardapio_time_travelled
end

Dado(/^que é (.*) na hora do (.*)$/) do |weekday, meal|
  hour, minute = { "café da manhã" => [ 8, 0 ], "almoço" => [ 12, 0 ], "jantar" => [ 18, 0 ] }.fetch(meal)
  set_cardapio_time(english_weekday(weekday), hour, minute)
end

Dado(/^que é (.+) (antes do café da manhã|depois do café da manhã e antes do almoço|depois do almoço e antes do jantar|depois do jantar)$/) do |weekday, moment|
  hour, minute = {
    "antes do café da manhã" => [ 6, 0 ],
    "depois do café da manhã e antes do almoço" => [ 10, 0 ],
    "depois do almoço e antes do jantar" => [ 15, 0 ],
    "depois do jantar" => [ 20, 0 ]
  }.fetch(moment)
  set_cardapio_time(english_weekday(weekday), hour, minute)
end

Então(/^devo ver o cardápio do (café da manhã|almoço|jantar) de (.*)$/) do |meal, weekday|
  expected_weekday = portuguese_weekday(english_weekday(weekday))
  expected_meal = {
    "café da manhã" => "Café da Manhã",
    "almoço" => "Almoço",
    "jantar" => "Janta"
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

def english_weekday(weekday)
  case weekday
  when /[Dd]omingo/
    'Sunday'
  when /[Ss]egunda-(?:[Ff]eira)?/
    'Monday'
  when /[Tt]erça-(?:[Ff]eira)?/
    'Tuesday'
  when /[Qq]uarta-(?:[Ff]eira)?/
    'Wednesday'
  when /[Qq]uinta-(?:[Ff]eira)?/
    'Thursday'
  when /[Ss]exta-(?:[Ff]eira)?/
    'Friday'
  when /[Ss]ábado/
    'Saturday'
  else
    raise "Invalid weekday at #{__FILE__}:#{__LINE__}"
  end
end
