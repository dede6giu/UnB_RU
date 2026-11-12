module AccessPointsHelper
  TURNSTILE_STATUS = {
    "Ativa" => [ "Pronta", "theme-success" ],
    "Inativa" => [ "Inativa", "theme-danger" ],
    "Operando" => [ "Em operação", "theme-warning" ],
    "FastPass" => [ "FastPass", "theme-info" ]
  }.freeze

  def turnstile_status_badge(turnstile)
    label, theme = TURNSTILE_STATUS.fetch(turnstile.operation)
    tag.span(label, class: "badge badge-subtle #{theme}")
  end

  def restaurant_label(restaurant)
    "#{restaurant.name} - #{restaurant.campus}"
  end
end
