class Turnstile < ApplicationRecord
    belongs_to :restaurant, foreign_key: :restaurant_id, optional: false
end
