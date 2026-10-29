class Turnstile < ApplicationRecord
  belongs_to :restaurant, foreign_key: :restaurant_id, optional: false
  validates :name, presence: true
  validates :operation, presence: true
  validates :restaurant_id, presence: true
  validates :name, uniqueness: { scope: :restaurant_id }
  validate :operation_valid_values

  def operation_valid_values
    unless %w[Inativa Ativa Operando FastPass].include?(operation)
      errors.add(:operation, "invalid '#{operation}' state")
    end
  end
end
