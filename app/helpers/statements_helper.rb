module StatementsHelper
  PAYMENT_LABELS = { "pix" => "PIX", "credit_card" => "Cartão de Crédito" }

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

  # O app guarda em UTC; o extrato mostra o horário de Brasília.
  def entry_time(transaction)
    transaction.created_at.in_time_zone("Brasilia").strftime("%d/%m/%Y %H:%M")
  end
end
