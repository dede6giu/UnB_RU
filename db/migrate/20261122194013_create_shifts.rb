class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts, if_not_exists: true do |t|
      t.string :meal_type, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false

      t.timestamps
    end

    add_index :shifts, :meal_type, unique: true, if_not_exists: true
  end
end
