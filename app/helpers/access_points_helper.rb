# Funções auxiliadores para as views do AccessPoints
module AccessPointsHelper
  TURNSTILE_STATUS = {
    "Ativa" => [ "Pronta", "theme-success" ],
    "Inativa" => [ "Inativa", "theme-danger" ],
    "Operando" => [ "Em operação", "theme-warning" ],
    "FastPass" => [ "FastPass", "theme-info" ]
  }.freeze

  ##
  # Recebe uma catraca e formata os valores de classe de css e
  # também conteúdo interno de uma tag de acordo com o valor de
  # operation da catraca.
  def turnstile_status_badge(turnstile)
    label, theme = TURNSTILE_STATUS.fetch(turnstile.operation)
    tag.span(label, class: "badge badge-subtle #{theme}")
  end

  ##
  # Recebe um restaurante e retorna uma string no formato:
  #   "NOME - CAMPUS"
  def restaurant_label(restaurant)
    "#{restaurant.name} - #{restaurant.campus}"
  end
end
