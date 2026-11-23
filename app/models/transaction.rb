# Lançamento do extrato de um estudante: crédito (recarga da carteira) ou débito (refeição paga com o
# saldo). Os métodos de classe montam as consultas e os totais do Extrato e Histórico de Refeições.
class Transaction < ApplicationRecord
  # Tipos de lançamento. credit: recarga da carteira; debit: refeição paga com o saldo.
  KINDS = %w[credit debit]
  # Meios de pagamento aceitos numa recarga.
  PAYMENT_METHODS = %w[pix credit_card]
  # Lançamentos por página do extrato.
  PER_PAGE = 10

  belongs_to :student

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: KINDS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, if: -> { kind == "credit" }

  ##
  # Só os débitos (refeições).
  #
  # Não recebe argumentos. Retorna uma consulta de Transaction; não altera o banco.
  def self.debits
    where(kind: "debit")
  end

  ##
  # Só os créditos (recargas).
  #
  # Não recebe argumentos. Retorna uma consulta de Transaction; não altera o banco.
  def self.credits
    where(kind: "credit")
  end

  ##
  # Total gasto com refeições, em centavos.
  #
  # Não recebe argumentos. Retorna um inteiro (0 sem débitos); não altera o banco.
  def self.spent_cents
    debits.sum(:amount_cents)
  end

  ##
  # Quantidade de refeições: cada débito é uma refeição.
  #
  # Não recebe argumentos. Retorna um inteiro; não altera o banco.
  def self.meals_count
    debits.count
  end

  ##
  # Total recarregado, em centavos.
  #
  # Não recebe argumentos. Retorna um inteiro (0 sem créditos); não altera o banco.
  def self.recharged_cents
    credits.sum(:amount_cents)
  end

  ##
  # Filtra pelo período escolhido no extrato.
  #
  # Recebe `"this_month"` (este mês), `"all"` (todo o período) ou qualquer outro valor (inclusive `nil`),
  # que vale o padrão da tela: últimos 30 dias. Retorna uma consulta; não altera o banco.
  def self.in_period(period)
    case period
    when "this_month" then where("created_at >= ?", Time.current.beginning_of_month)
    when "all" then all
    else where("created_at >= ?", 30.days.ago)
    end
  end

  ##
  # Filtra pelo tipo escolhido no extrato.
  #
  # Recebe `"credit"` (recargas), `"meal"` (refeições) ou qualquer outro valor, que mantém todos.
  # Retorna uma consulta; não altera o banco.
  def self.of_type(type)
    case type
    when "credit" then credits
    when "meal" then debits
    else all
    end
  end

  ##
  # Uma página do extrato, com PER_PAGE lançamentos.
  #
  # Recebe o número da página (começa em 1). Retorna uma consulta; não altera o banco.
  def self.page(number)
    offset((number - 1) * PER_PAGE).limit(PER_PAGE)
  end

  ##
  # Quantidade de páginas do extrato. Sem lançamentos ainda existe uma página, a que mostra o aviso.
  #
  # Não recebe argumentos. Retorna um inteiro, no mínimo 1; não altera o banco.
  def self.total_pages
    [ (count / PER_PAGE.to_f).ceil, 1 ].max
  end
end
