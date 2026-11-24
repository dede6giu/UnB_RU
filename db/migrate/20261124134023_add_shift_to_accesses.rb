class AddShiftToAccesses < ActiveRecord::Migration[8.1]
  def change
    add_reference :accesses, :shift, foreign_key: true
  end
end
