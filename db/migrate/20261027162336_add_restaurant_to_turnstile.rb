class AddRestaurantToTurnstile < ActiveRecord::Migration[8.1]
  def change
    add_reference :turnstiles, :restaurant, null: false, foreign_key: true
  end
end
