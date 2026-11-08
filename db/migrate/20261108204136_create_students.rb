class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :name
      t.string :registration
      t.decimal :balance

      t.timestamps
    end
  end
end
