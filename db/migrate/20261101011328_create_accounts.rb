class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :user
      t.string :name
      t.string :password_digest
      t.string :role

      t.timestamps
    end
    add_index :accounts, :user, unique: true
  end
end
