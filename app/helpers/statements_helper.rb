# Helpers do Extrato e Histórico de Refeições: textos de cada lançamento e dos filtros. Usados na view
# do extrato e no PDF (StatementPdf).
module StatementsHelper
  # Nome de cada meio de pagamento na tela.
  PAYMENT_LABELS = { "pix" => "PIX", "credit_card" => "Cartão de Crédito" }
  # Opções do filtro de período: [texto na tela, valor do parâmetro]. A primeira é o padrão.
  PERIOD_OPTIONS = [ [ "Últimos 30 dias", "last_30_days" ], [ "Este mês", "this_month" ], [ "Todo o período", "all" ] ]
  # Opções do filtro de tipo: [texto na tela, valor do parâmetro]. A primeira é o padrão.
  TYPE_OPTIONS = [ [ "Todos", "all" ], [ "Recargas", "credit" ], [ "Refeições", "meal" ] ]

  ##
  # Nome do lançamento: "Recarga de Saldo" para crédito e "Refeição" para débito.
  #
  # Recebe a Transaction. Retorna o texto; sem efeitos colaterais.
  def entry_label(transaction)
    transaction.kind == "credit" ? "Recarga de Saldo" : "Refeição"
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
  # Procura o texto de uma opção pelo valor; se não achar, usa a primeira opção, que é o padrão.
  #
  # Recebe a lista de opções (`[texto, valor]`) e o valor procurado. Retorna o texto; sem efeitos
  # colaterais.
  def option_label(options, value)
    option = options.find { |opcao| opcao.last == value }
    (option || options.first).first
  end
end
