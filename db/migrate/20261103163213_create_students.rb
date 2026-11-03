class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.integer :balance_cents, null: false, default: 0

      t.timestamps
    end
  end
end
