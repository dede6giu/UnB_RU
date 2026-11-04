class Student < ApplicationRecord
  belongs_to :account

  # Dinheiro em centavos inteiros (R$ 12,50 = 1250): o SQLite guarda decimal
  # como ponto flutuante, que perde precisão.
  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }
end
