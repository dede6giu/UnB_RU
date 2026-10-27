class Restaurant < ApplicationRecord
    has_many :turnstiles, dependent: :destroy
end
