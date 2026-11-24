# Helpers do Extrato e Histórico de Refeições: textos de cada lançamento e dos filtros. Usados na view
# do extrato e no PDF (StatementPdf).
module StatementsHelper
  # Nome de cada meio de pagamento na tela.
  PAYMENT_LABELS = { "pix" => "PIX", "credit_card" => "Cartão de Crédito" }
  # Opções do filtro de período: [texto na tela, valor do parâmetro]. A primeira é o padrão.
  PERIOD_OPTIONS = [ [ "Últimos 30 dias", "last_30_days" ], [ "Este mês", "this_month" ], [ "Todo o período", "all" ] ]
  # Nome de cada refeição, pelo turno do acesso.
  MEAL_LABELS = { "breakfast" => "Café da manhã", "lunch" => "Almoço", "dinner" => "Jantar" }
  # Opções do filtro de tipo: [texto na tela, valor do parâmetro]. A primeira é o padrão.
  TYPE_OPTIONS = [ [ "Todos", "all" ], [ "Recargas", "credit" ], [ "Refeições", "meal" ],
                   [ "Café da manhã", "breakfast" ], [ "Almoço", "lunch" ], [ "Jantar", "dinner" ] ]

  ##
  # Nome do lançamento: "Recarga de Saldo" para crédito; para débito, o nome da refeição pelo turno do
  # acesso ("Almoço"), ou "Refeição" quando não há turno.
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def entry_label(transaction)
    return "Recarga de Saldo" if transaction.kind == "credit"

    MEAL_LABELS.fetch(transaction.access&.shift&.meal_type, "Refeição")
  end

  ##
  # Onde foi a refeição: "restaurante · catraca", pelo acesso; "—" quando não há acesso (como na recarga).
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def place_label(transaction)
    return "—" if transaction.access.nil?

    "#{transaction.access.restaurant.name} · #{transaction.access.turnstile.name}"
  end

  ##
  # Meio de pagamento do lançamento ("PIX" ou "Cartão de Crédito"); a refeição, que é paga com o saldo,
  # aparece como "Saldo em carteira".
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def payment_label(transaction)
    PAYMENT_LABELS.fetch(transaction.payment_method, "Saldo em carteira")
  end

  ##
  # Valor com sinal: "+ R$ 22,50" para recarga e "- R$ 4,50" para refeição.
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def signed_amount(transaction)
    sign = transaction.kind == "credit" ? "+" : "-"
    "#{sign} #{reais(transaction.amount_cents)}"
  end

  ##
  # Data e hora do lançamento no formato dd/mm/aaaa hh:mm.
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def entry_time(transaction)
    transaction.created_at.strftime("%d/%m/%Y %H:%M")
  end

  ##
  # Texto do período escolhido (por exemplo "Este mês"); um valor desconhecido vira o padrão.
  #
  # Recebe o valor do parâmetro `period` (pode ser `nil`). Retorna o texto; sem efeitos colaterais.
  def period_label(period)
    option_label(PERIOD_OPTIONS, period)
  end

  ##
  # Texto do tipo escolhido (por exemplo "Refeições"); um valor desconhecido vira o padrão.
  #
  # Recebe o valor do parâmetro `type` (pode ser `nil`). Retorna o texto; sem efeitos colaterais.
  def type_label(type)
    option_label(TYPE_OPTIONS, type)
  end

  ##
  # Nome do restaurante escolhido no filtro; "Todos" quando não há filtro ou o id não existe.
  #
  # Recebe o valor do parâmetro `restaurant` (pode ser `nil`). Retorna o texto; não altera o banco.
  def restaurant_label(restaurant_id)
    restaurant = Restaurant.find_by(id: restaurant_id)
    restaurant ? restaurant.name : "Todos"
  end

  ##
  # Procura o texto de uma opção pelo valor; se não achar, usa a primeira opção, que é o padrão.
  #
  # Recebe a lista de opções (`[texto, valor]`) e o valor procurado. Retorna o texto; sem efeitos
  # colaterais.
  def option_label(options, value)
    option = options.find { |opcao| opcao.last == value }
    (option || options.first).first
  end
end
