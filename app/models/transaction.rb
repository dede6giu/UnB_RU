class Transaction < ApplicationRecord
  # credit: recarga da carteira; debit: refeição paga com o saldo.
  KINDS = %w[credit debit]
  PAYMENT_METHODS = %w[pix credit_card]
  PER_PAGE = 10

  belongs_to :student

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: KINDS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, if: -> { kind == "credit" }

  def self.debits
    where(kind: "debit")
  end

  def self.credits
    where(kind: "credit")
  end

  # sem período, ou com um que não existe, vale o padrão da tela: últimos 30 dias
  def self.in_period(period)
    case period
    when "this_month" then where("created_at >= ?", Time.current.beginning_of_month)
    when "all" then all
    else where("created_at >= ?", 30.days.ago)
    end
  end

  def self.page(number)
    offset((number - 1) * PER_PAGE).limit(PER_PAGE)
  end

  # sem lançamentos ainda existe uma página, a que mostra o aviso
  def self.total_pages
    [ (count / PER_PAGE.to_f).ceil, 1 ].max
  end
end
