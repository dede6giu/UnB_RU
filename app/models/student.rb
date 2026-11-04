class Student < ApplicationRecord
  belongs_to :account
  has_many :transactions

  # Dinheiro em centavos inteiros (R$ 12,50 = 1250): o SQLite guarda decimal
  # como ponto flutuante, que perde precisão.
  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }

  def add_credit(amount_cents, payment_method)
    lancamento = Transaction.new(student: self, kind: "credit",
                                 amount_cents: amount_cents, payment_method: payment_method)
    return false unless lancamento.valid?

    transaction do
      lancamento.save!
      increment!(:balance_cents, amount_cents)
    end
    true
  end
end
