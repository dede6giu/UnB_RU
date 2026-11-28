# Textos da tela do FastPass do estudante.
module FastpassHelper
  # Nome de cada refeição na tela.
  MEAL_LABELS = { "breakfast" => "Café da manhã", "lunch" => "Almoço", "dinner" => "Jantar" }.freeze

  # Texto de cada fase do FastPass (ver FastPassCycle#status_of).
  STATUS_LABELS = {
    "open" => "Inscrição aberta",
    "pending" => "Sorteio realizado",
    "active" => "Em andamento",
    "inactive" => "Inativo",
    "unavailable" => "Sem FastPass"
  }.freeze

  ##
  # Recebe o `meal_type` do turno ("breakfast", "lunch" ou "dinner"). Retorna o nome da refeição em
  # português; sem efeitos colaterais.
  def meal_label(meal_type)
    MEAL_LABELS.fetch(meal_type)
  end

  ##
  # Recebe a fase do FastPass (de FastPassCycle#status_of). Retorna o texto da fase para a tela; sem
  # efeitos colaterais.
  def fastpass_status_label(status)
    STATUS_LABELS.fetch(status)
  end
end
