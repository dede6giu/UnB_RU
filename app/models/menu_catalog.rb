require "json"

class MenuCatalog
  WEEKDAYS = [
    ["domingo", "Domingo"],
    ["segunda-feira", "Segunda-feira"],
    ["terca-feira", "Terça-feira"],
    ["quarta-feira", "Quarta-feira"],
    ["quinta-feira", "Quinta-feira"],
    ["sexta-feira", "Sexta-feira"],
    ["sabado", "Sábado"]
  ].freeze

  MEALS = [
    ["cafe_da_manha", "Café da Manhã"],
    ["almoco", "Almoço"],
    ["jantar", "Janta"]
  ].freeze

  def initialize(path: Rails.root.join("cardapio.json"))
    @menus = JSON.parse(File.read(path))
  end

  def weekdays
    WEEKDAYS.map(&:last)
  end

  def menus_for(weekday_index)
    day_key = WEEKDAYS.fetch(weekday_index).first
    day = @menus.fetch(day_key)

    MEALS.filter_map do |meal_key, label|
      content = day[meal_key]
      { key: meal_key, label: label, content: content } if content
    end
  end
end
