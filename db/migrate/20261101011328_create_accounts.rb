class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: false do |t|
      t.string :user, primary_key: true
      t.string :name
      t.string :password_digest
      t.string :role

      t.timestamps
    end
  end
end
