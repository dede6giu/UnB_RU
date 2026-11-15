class Timeframe < ApplicationRecord
  belongs_to :shift
  has_many :fast_pass_enrollments, dependent: :restrict_with_error

  validates :starts_at, :ends_at, presence: true
  validate :must_fit_inside_shift
  validate :end_must_follow_start

  private

  def must_fit_inside_shift
    return if shift.blank? || starts_at.blank? || ends_at.blank?

    errors.add(:base, "O time-frame deve estar dentro do turno da refeição.") if
      starts_at < shift.starts_at || ends_at > shift.ends_at
  end

  def end_must_follow_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "deve ser posterior ao início do time-frame")
  end
end
