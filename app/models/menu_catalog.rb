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

  FIELD_LABELS = {
    "bebidas" => "Bebidas", "panificacao" => "Panificação", "opcao_extra" => "Opção extra",
    "gordura" => "Gordura", "complemento_padrao" => "Complemento padrão",
    "complemento_ovolactovegetariano" => "Complemento ovolactovegetariano",
    "complemento_vegetariano_estrito" => "Complemento vegetariano estrito", "fruta" => "Fruta",
    "salada_1" => "Salada 1", "salada_2" => "Salada 2", "molho_para_salada" => "Molho para salada",
    "prato_principal_padrao" => "Prato principal padrão",
    "prato_principal_ovolactovegetariano" => "Prato principal ovolactovegetariano",
    "prato_principal_vegetariano_estrito" => "Prato principal vegetariano estrito",
    "guarnicao" => "Guarnição", "acompanhamentos" => "Acompanhamentos",
    "sobremesa" => "Sobremesa", "bebida" => "Bebida", "sopa" => "Sopa", "torrada" => "Torrada"
  }.freeze

  SERVING_WINDOWS = {
    "cafe_da_manha" => [7 * 60 * 60, 9 * 60 * 60 + 30 * 60],
    "almoco" => [11 * 60 * 60, 14 * 60 * 60 + 30 * 60],
    "jantar" => [17 * 60 * 60, 19 * 60 * 60 + 30 * 60]
  }.freeze

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

  def current_meal_at(time = Time.current)
    seconds = time.seconds_since_midnight
    SERVING_WINDOWS.find do |_meal_key, (starts_at, ends_at)|
      starts_at <= seconds && seconds < ends_at
    end&.first
  end

  def widget_menu_at(time = Time.current)
    current_meal_key = current_meal_at(time)
    seconds = time.seconds_since_midnight

    if current_meal_key
      weekday_index = time.wday
      meal_key = current_meal_key
      current = true
    elsif seconds < SERVING_WINDOWS.fetch("almoco").first
      # The widget feature explicitly expects lunch before breakfast as well
      # as between breakfast and lunch.
      weekday_index = time.wday
      meal_key = "almoco"
      current = false
    elsif seconds < SERVING_WINDOWS.fetch("jantar").first
      weekday_index = time.wday
      meal_key = "jantar"
      current = false
    else
      weekday_index = (time.wday + 1) % WEEKDAYS.length
      meal_key = "cafe_da_manha"
      current = false
    end

    menus_for(weekday_index).find { |menu| menu[:key] == meal_key }.merge(
      weekday_index: weekday_index,
      current: current
    )
  end
end
