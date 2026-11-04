class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :student, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :payment_method
      t.integer :amount_cents, null: false

      t.timestamps
    end
  end
end
