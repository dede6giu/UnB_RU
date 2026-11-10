class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.string :student_id, null: false, index: true
      # a chave estrangeira do acesso entra junto com a tabela de acessos
      t.integer :access_id, index: true
      t.string :kind, null: false
      t.string :payment_method
      t.integer :amount_cents, null: false

      t.timestamps
    end
    add_foreign_key :transactions, :students, column: :student_id, primary_key: :user
  end
end
