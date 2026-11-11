module StatementsHelper
  PAYMENT_LABELS = { "pix" => "PIX", "credit_card" => "Cartão de Crédito" }
  PERIOD_OPTIONS = [ [ "Últimos 30 dias", "last_30_days" ], [ "Este mês", "this_month" ], [ "Todo o período", "all" ] ]
  TYPE_OPTIONS = [ [ "Todos", "all" ], [ "Recargas", "credit" ], [ "Refeições", "meal" ] ]

  def entry_label(transaction)
    transaction.kind == "credit" ? "Recarga de Saldo" : "Refeição"
  end

  def payment_label(transaction)
    PAYMENT_LABELS.fetch(transaction.payment_method, "Saldo em carteira")
  end

  def signed_amount(transaction)
    sign = transaction.kind == "credit" ? "+" : "-"
    "#{sign} #{reais(transaction.amount_cents)}"
  end

  def entry_time(transaction)
    transaction.created_at.strftime("%d/%m/%Y %H:%M")
  end

  def period_label(period)
    option_label(PERIOD_OPTIONS, period)
  end

  def type_label(type)
    option_label(TYPE_OPTIONS, type)
  end

  # a primeira opção é o padrão, o mesmo que o Transaction.in_period e o of_type usam
  def option_label(options, value)
    option = options.find { |opcao| opcao.last == value }
    (option || options.first).first
  end
end
