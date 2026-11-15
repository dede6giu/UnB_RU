class FastPassEnrollment < ApplicationRecord
  belongs_to :student, foreign_key: :student_id, primary_key: :user
  belongs_to :timeframe

  validates :student_id, uniqueness: { scope: :timeframe_id }
end
