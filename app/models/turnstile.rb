class Turnstile < ApplicationRecord
  belongs_to :restaurant, foreign_key: :restaurant_id, optional: false
  validates :name, presence: { message: "Nome não pode ser vazio" }
  validates :operation, presence: { message: "Operação não pode ser vazio" }
  validates :restaurant_id, presence: { message: "Catraca tem que estar associada a um restaurante" }
  validates :name, uniqueness: { scope: :restaurant_id, message: "Catraca já existente" }
  belongs_to :operator, class_name: "Account", optional: true
  validate :operation_valid_values
  validate :inactive_active_while_operator
  before_destroy :check_operating, prepend: true do
    throw(:abort) if errors.present?
  end

  def operation_valid_values
    unless %w[Inativa Ativa Operando FastPass].include?(operation)
      errors.add(:operation, "Modo de operação inválido")
    end
  end

  def check_operating
    errors.add(:operating, "Um operador está atuando na catraca") unless
      operator_id == nil
  end

  def inactive_active_while_operator
    if %w[ Inativa Ativa ].include?(operation)
      errors.add(:operating, "Um operador está atuando na catraca") unless
        operator_id == nil
    end
  end
end
