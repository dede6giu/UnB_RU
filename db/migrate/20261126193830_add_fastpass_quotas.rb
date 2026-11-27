class AddFastpassQuotas < ActiveRecord::Migration[8.1]
  def change
    add_column :timeframes, :quota, :integer
    add_column :fast_pass_settings, :default_quota, :integer, null: false, default: 30
    add_column :turnstiles, :capacity, :integer
    add_column :turnstiles, :fastpass_corridor, :boolean, null: false, default: false
    add_column :fast_pass_enrollments, :status, :string, null: false, default: "enrolled"
  end
end
