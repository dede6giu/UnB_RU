class AddUniqueIndexToRestaurant < ActiveRecord::Migration[8.1]
  def change
    add_index :restaurants, [ :name, :campus ], unique: true
  end
end
