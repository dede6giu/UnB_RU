class AddOperatorToTurnstiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :turnstiles, :operator, foreign_key: { to_table: :accounts }
  end
end
