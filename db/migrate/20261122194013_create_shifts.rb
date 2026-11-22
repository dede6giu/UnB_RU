class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts do |t|
      t.string :meal_type, null: false
      t.string :starts_at, null: false
      t.string :ends_at, null: false

      t.timestamps
    end

    add_index :shifts, :meal_type, unique: true
  end
end
