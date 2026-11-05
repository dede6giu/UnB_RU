class Restaurant < ApplicationRecord
    has_many :turnstiles, dependent: :destroy
    validates :name, presence: true
    validates :campus, presence: true
    validates :name, uniqueness: { scope: :campus }
end
