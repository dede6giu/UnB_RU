class Student < ApplicationRecord
  belongs_to :account, foreign_key: :user, inverse_of: :student
  has_many :transactions

  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }

  def add_credit(amount_cents, payment_method)
    lancamento = Transaction.new(student: self, kind: "credit",
                                 amount_cents: amount_cents, payment_method: payment_method)
    return false unless lancamento.valid?

    transaction do
      lancamento.save!
      # soma direto no banco, assim duas recargas ao mesmo tempo não se perdem
      increment!(:balance_cents, amount_cents)
    end
    true
  end

  def add_debit(amount_cents)
    lancamento = Transaction.new(student: self, kind: "debit",
                                 amount_cents: amount_cents)
    return false unless lancamento.valid?

    transaction do
      lancamento.save!
      decrement!(:balance_cents, amount_cents)
    end
    true
  end
end
