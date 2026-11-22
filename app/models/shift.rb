class Shift < ApplicationRecord
  MEAL_TYPES = %w[breakfast lunch dinner].freeze
  TIME_FORMAT = /\A(?:[01]\d|2[0-3]):[0-5]\d\z/

  validates :meal_type, presence: true, inclusion: { in: MEAL_TYPES }, uniqueness: true
  validates :starts_at, :ends_at, presence: true, format: { with: TIME_FORMAT, allow_blank: true }
  validate :end_must_follow_start
  validate :must_not_overlap_another_shift

  private

  def end_must_follow_start
    return unless valid_time?(starts_at) && valid_time?(ends_at)
    return if starts_at < ends_at

    errors.add(:ends_at, "deve ser posterior ao início do turno")
  end

  def must_not_overlap_another_shift
    return unless valid_time?(starts_at) && valid_time?(ends_at)

    overlaps = self.class.where.not(id: id).where.not(meal_type: meal_type).any? do |shift|
      starts_at < shift.ends_at && ends_at > shift.starts_at
    end
    errors.add(:base, "O turno não pode se sobrepor a outra refeição.") if overlaps
  end

  def valid_time?(value)
    value.is_a?(String) && TIME_FORMAT.match?(value)
  end
end
