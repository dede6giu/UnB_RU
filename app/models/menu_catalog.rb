require "json"

# Catálogo do cardápio semanal do RU, lido de `cardapio.json`.
#
# Não é um model do ActiveRecord: não usa o banco de dados. Responde qual é o
# cardápio de cada dia e refeição, qual refeição está sendo servida em um
# horário e qual refeição o widget do Portal do Estudante deve mostrar.
class MenuCatalog
  # Dias da semana na ordem de `Time#wday` (0 = domingo), como pares
  # [chave no JSON, nome exibido].
  WEEKDAYS = [
    [ "domingo", "Domingo" ],
    [ "segunda-feira", "Segunda-feira" ],
    [ "terca-feira", "Terça-feira" ],
    [ "quarta-feira", "Quarta-feira" ],
    [ "quinta-feira", "Quinta-feira" ],
    [ "sexta-feira", "Sexta-feira" ],
    [ "sabado", "Sábado" ]
  ].freeze

  # Refeições na ordem do dia, como pares [chave no JSON, nome exibido].
  MEALS = [
    [ "cafe_da_manha", "Café da Manhã" ],
    [ "almoco", "Almoço" ],
    [ "jantar", "Janta" ]
  ].freeze

  # Nome exibido para cada campo de um cardápio no JSON.
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

  # Horário de cada refeição, em segundos desde a meia-noite, como
  # [início, fim). O fim não faz parte do horário.
  SERVING_WINDOWS = {
    "cafe_da_manha" => [ 7 * 60 * 60, 9 * 60 * 60 + 30 * 60 ],
    "almoco" => [ 11 * 60 * 60, 14 * 60 * 60 + 30 * 60 ],
    "jantar" => [ 17 * 60 * 60, 19 * 60 * 60 + 30 * 60 ]
  }.freeze

  ##
  # Carrega o cardápio semanal.
  #
  # Recebe `path:`, o caminho do JSON (padrão: `cardapio.json` na raiz do projeto).
  # Lê o arquivo do disco e guarda o conteúdo em `@menus`. Não altera o banco de dados.
  # Levanta `Errno::ENOENT` se o arquivo não existe e `JSON::ParserError` se o JSON é inválido.
  def initialize(path: Rails.root.join("cardapio.json"))
    @menus = JSON.parse(File.read(path))
  end

  ##
  # Lista os nomes dos dias da semana para exibição.
  #
  # Não recebe argumentos. Retorna um array de strings, de "Domingo" a "Sábado",
  # na ordem de `Time#wday`. Não tem efeitos colaterais.
  def weekdays
    WEEKDAYS.map(&:last)
  end

  ##
  # Lista as refeições cadastradas de um dia da semana.
  #
  # Recebe `weekday_index`, de 0 (domingo) a 6 (sábado).
  # Retorna um array de hashes `{ key:, label:, content: }`, na ordem café, almoço e
  # janta. Refeições sem conteúdo no JSON ficam de fora. Não tem efeitos colaterais.
  # Levanta `IndexError` se o índice está fora de 0..6 e `KeyError` se o dia não está no JSON.
  def menus_for(weekday_index)
    day_key = WEEKDAYS.fetch(weekday_index).first
    day = @menus.fetch(day_key)

    MEALS.filter_map do |meal_key, label|
      content = day[meal_key]
      { key: meal_key, label: label, content: content } if content
    end
  end

  ##
  # Descobre qual refeição está sendo servida em um horário.
  #
  # Recebe `time` (padrão: agora).
  # Retorna a chave da refeição (`"cafe_da_manha"`, `"almoco"` ou `"jantar"`), ou `nil`
  # quando o horário não está em nenhuma das janelas de SERVING_WINDOWS.
  # Não tem efeitos colaterais.
  def current_meal_at(time = Time.current)
    seconds = time.seconds_since_midnight
    SERVING_WINDOWS.find do |_meal_key, (starts_at, ends_at)|
      starts_at <= seconds && seconds < ends_at
    end&.first
  end

  ##
  # Monta o cardápio que o widget do Portal do Estudante mostra em um horário.
  #
  # Recebe `time` (padrão: agora). A escolha da refeição fica em #widget_meal_at.
  # Retorna o hash de #menus_for para essa refeição, mais `weekday_index` (o dia do
  # cardápio) e `current` (`true` se a refeição está sendo servida agora).
  # Não tem efeitos colaterais.
  def widget_menu_at(time = Time.current)
    weekday_index, meal_key, current = widget_meal_at(time)

    menus_for(weekday_index).find { |menu| menu[:key] == meal_key }.merge(
      weekday_index: weekday_index,
      current: current
    )
  end

  private

  ##
  # Decide qual refeição o widget mostra em um horário.
  #
  # Recebe `time`. Durante uma refeição, escolhe essa refeição. Antes do almoço
  # (inclusive antes do café), escolhe o almoço. Entre o almoço e a janta, escolhe a
  # janta. Depois da janta, escolhe o café da manhã do dia seguinte.
  # Retorna `[weekday_index, meal_key, current]`. `current` é `true` só quando a
  # refeição está sendo servida. Não tem efeitos colaterais.
  def widget_meal_at(time)
    current_meal_key = current_meal_at(time)
    return [ time.wday, current_meal_key, true ] if current_meal_key
    seconds = time.seconds_since_midnight
    weekday_index = time.wday

    if seconds < meal_starts_at("almoco")
      # The widget feature explicitly expects lunch before breakfast as well
      # as between breakfast and lunch.
      meal_key = "almoco"
    elsif seconds < meal_starts_at("jantar")
      meal_key = "jantar"
    else
      weekday_index = (time.wday + 1) % WEEKDAYS.length
      meal_key = "cafe_da_manha"
    end

    [ weekday_index, meal_key, false ]
  end

  ##
  # Informa quando uma refeição começa a ser servida.
  #
  # Recebe `refeicao`, a chave da refeição (`"cafe_da_manha"`, `"almoco"` ou `"jantar"`).
  # Retorna o início da janela em segundos desde a meia-noite. Não tem efeitos colaterais.
  # Levanta `KeyError` se a refeição não existe em SERVING_WINDOWS.
  def meal_starts_at(refeicao)
    SERVING_WINDOWS.fetch(refeicao).first
  end
end
