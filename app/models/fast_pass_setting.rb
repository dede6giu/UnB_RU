class FastPassSetting < ApplicationRecord
  validates :delay_tolerance_minutes,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :early_release_minutes,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.global
    find_or_create_by!(singleton: true)
  end
end
