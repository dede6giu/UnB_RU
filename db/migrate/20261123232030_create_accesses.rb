class CreateAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :accesses do |t|
      t.string :student_id, index: true
      t.string :registration, null: false
      t.references :restaurant, null: false, foreign_key: true
      t.references :turnstile, null: false, foreign_key: true
      t.string :status, null: false
      t.string :reason

      t.timestamps
    end

    add_foreign_key :accesses, :students, column: :student_id, primary_key: :user
    add_foreign_key :transactions, :accesses, column: :access_id
  end
end
