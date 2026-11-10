class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students, id: false do |t|
      t.string :user, primary_key: true
      t.integer :balance_cents, null: false, default: 0
      t.datetime :blocked_until

      t.timestamps
    end
    add_foreign_key :students, :accounts, column: :user, primary_key: :user
  end
end
