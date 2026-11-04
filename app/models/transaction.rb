class Transaction < ApplicationRecord
  # credit: recarga da carteira; debit: refeição paga com o saldo.
  KINDS = %w[credit debit]
  PAYMENT_METHODS = %w[pix credit_card]

  belongs_to :student

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: KINDS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, if: -> { kind == "credit" }
end
