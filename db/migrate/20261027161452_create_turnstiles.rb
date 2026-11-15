class CreateTurnstiles < ActiveRecord::Migration[8.1]
  def change
    create_table :turnstiles do |t|
      t.string :name
      t.string :operation

      t.timestamps
    end
  end
end
