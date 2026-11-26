SHIFT_MEALS = { "café da manhã" => "breakfast", "almoço" => "lunch", "jantar" => "dinner" }.freeze

Dado(/^que estou logado como admin$/) do
  step "que sou um admin"
end

Dado(/^que o turno do (café da manhã|almoço|jantar) vai de "(\d{2}:\d{2})" até "(\d{2}:\d{2})"$/) do |refeicao, starts_at, ends_at|
  Shift.find_or_initialize_by(meal_type: SHIFT_MEALS.fetch(refeicao)).update!(starts_at: starts_at, ends_at: ends_at)
end

Quando(/^defino o turno do (café da manhã|almoço|jantar) de "(\d{2}:\d{2})" até "(\d{2}:\d{2})"$/) do |refeicao, starts_at, ends_at|
  meal = SHIFT_MEALS.fetch(refeicao)
  fill_in "shift-#{meal}-start", with: starts_at
  fill_in "shift-#{meal}-end", with: ends_at
end

Então(/^devo ver o turno do (café da manhã|almoço|jantar) indo de "(\d{2}:\d{2})" até "(\d{2}:\d{2})"$/) do |refeicao, starts_at, ends_at|
  meal_labels = { "café da manhã" => "Café da manhã", "almoço" => "Almoço", "jantar" => "Janta" }
  expect(page).to have_content("#{meal_labels.fetch(refeicao)}: #{starts_at}–#{ends_at}")
end
