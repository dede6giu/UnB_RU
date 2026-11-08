class Turnstile < ApplicationRecord
  belongs_to :restaurant, foreign_key: :restaurant_id, optional: false
  validates :name, presence: { message: "Nome não pode ser vazio" }
  validates :operation, presence: { message: "Operação não pode ser vazio" }
  validates :restaurant_id, presence: { message: "Catraca tem que estar associada a um restaurante" }
  validates :name, uniqueness: { scope: :restaurant_id, message: "Catraca já existente" }
  validate :operation_valid_values
  before_destroy :check_operating, prepend: true do
    throw(:abort) if errors.present?
  end

  def operation_valid_values
    unless %w[Inativa Ativa Operando FastPass].include?(operation)
      errors.add(:operation, "invalid '#{operation}' state")
    end
  end

  def check_operating
    # TODO: adicionar o cheque de operador
    errors.add(:operating, "A catraca está em operação") unless
      %w[ Inativa Ativa ].include?(operation)
  end
end
