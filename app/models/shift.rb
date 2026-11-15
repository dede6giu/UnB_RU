class Shift < ApplicationRecord
  MEAL_TYPES = %w[breakfast lunch dinner].freeze

  has_many :timeframes, dependent: :destroy

  validates :meal_type, presence: true, inclusion: { in: MEAL_TYPES }, uniqueness: true
  validates :starts_at, :ends_at, presence: true
  validate :end_must_follow_start
  validate :must_not_overlap_another_shift

  private

  def end_must_follow_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "deve ser posterior ao início do turno")
  end

  def must_not_overlap_another_shift
    return if starts_at.blank? || ends_at.blank? || meal_type.blank?

    overlapping_shift = self.class.where.not(id: id).where.not(meal_type: meal_type).find do |shift|
      starts_at < shift.ends_at && ends_at > shift.starts_at
    end
    errors.add(:base, "O turno não pode se sobrepor a outra refeição.") if overlapping_shift
  end
end
