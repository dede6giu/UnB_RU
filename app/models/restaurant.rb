class Restaurant < ApplicationRecord
  has_many :turnstiles, dependent: :destroy
  validates :name, presence: { message: "Nome não pode ser vazio" }
  validates :campus, presence: { message: "Campus não pode ser vazio" }
  validates :name, uniqueness: { scope: :campus, message: "Restaurante já existente" }
  before_destroy :check_operating_turnstiles, prepend: true do
    throw(:abort) if errors.present?
  end

  def check_operating_turnstiles
    errors.add(:operating_turnstiles, "Há catracas em operação") unless
      (Turnstile.all.where(restaurant_id: id, operation: %w[ Operando FastPass ]).count) == 0
  end
end
