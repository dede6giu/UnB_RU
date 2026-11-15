class CreateFastpassScheduling < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts do |t|
      t.string :meal_type, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false

      t.timestamps
    end
    add_index :shifts, :meal_type, unique: true

    create_table :timeframes do |t|
      t.references :shift, null: false, foreign_key: true
      t.time :starts_at, null: false
      t.time :ends_at, null: false

      t.timestamps
    end

    create_table :fast_pass_settings do |t|
      t.integer :delay_tolerance_minutes, null: false, default: 0
      t.integer :early_release_minutes, null: false, default: 0
      t.boolean :delay_tolerance_enabled, null: false, default: true
      t.boolean :singleton, null: false, default: true

      t.timestamps
    end
    add_index :fast_pass_settings, :singleton, unique: true

    create_table :fast_pass_enrollments do |t|
      t.string :student_id, null: false
      t.references :timeframe, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end
    add_index :fast_pass_enrollments, [ :student_id, :timeframe_id ], unique: true
    add_foreign_key :fast_pass_enrollments, :students,
                    column: :student_id, primary_key: :user
  end
end
