class Shift < ApplicationRecord
  MEAL_TYPES = %w[breakfast lunch dinner].freeze
  TIME_FORMAT = /\A(?:[01]\d|2[0-3]):[0-5]\d\z/

  validates :meal_type, presence: true, inclusion: { in: MEAL_TYPES }, uniqueness: true
  validates :starts_at, :ends_at, presence: true
  validate :time_values_must_be_valid
  validate :end_must_follow_start
  validate :must_not_overlap_another_shift

  ##
  # Acha o turno em que um horário cai (o início conta, o fim não).
  #
  # Recebe um horário (`Time`). Retorna o Shift daquele horário, ou `nil` fora dos turnos.
  # Não altera o banco. Os horários do turno vêm com a data 2000-01-01, então compara só a hora do dia.
  def self.at(time)
    seconds = time.seconds_since_midnight
    all.find do |shift|
      shift.starts_at.seconds_since_midnight <= seconds && seconds < shift.ends_at.seconds_since_midnight
    end
  end

  private

  def time_values_must_be_valid
    %i[starts_at ends_at].each do |attribute|
      value = public_send(attribute)
      next if value.blank? || valid_time?(value)

      errors.add(attribute, :invalid)
    end
  end

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
    return TIME_FORMAT.match?(value) if value.is_a?(String)

    value.respond_to?(:hour) && value.respond_to?(:min)
  end
end
