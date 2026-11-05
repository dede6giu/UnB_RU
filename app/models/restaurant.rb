class Restaurant < ApplicationRecord
    has_many :turnstiles, dependent: :destroy
    validates :name, presence: { message: "Nome não pode ser vazio" }
    validates :campus, presence: { message: "Campus não pode ser vazio" }
    validates :name, uniqueness: { scope: :campus, message: "Restaurante já existente" }
end
