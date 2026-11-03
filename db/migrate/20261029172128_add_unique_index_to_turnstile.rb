class AddUniqueIndexToTurnstile < ActiveRecord::Migration[8.1]
  def change
    add_index :turnstiles, [ :name, :restaurant_id ], unique: true
  end
end
