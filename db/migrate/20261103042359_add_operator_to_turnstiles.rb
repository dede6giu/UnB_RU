class AddOperatorToTurnstiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :turnstiles, :operator, type: :string, foreign_key: { to_table: :accounts, primary_key: :user }
  end
end
