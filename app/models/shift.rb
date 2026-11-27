# Turno de uma refeição (café, almoço ou jantar), com o horário de início e de fim, configurado pelo
# admin. Os turnos não podem se sobrepor. O acesso guarda o turno em que aconteceu.
class Shift < ApplicationRecord
  # Refeições que têm turno.
  MEAL_TYPES = %w[breakfast lunch dinner].freeze
  # Horário no formato HH:MM, de 00:00 a 23:59.
  TIME_FORMAT = /\A(?:[01]\d|2[0-3]):[0-5]\d\z/

  has_many :timeframes, dependent: :destroy

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

  ##
  # Validação: início e fim precisam ser horários (HH:MM).
  #
  # Não recebe argumentos. Acrescenta um erro no campo inválido; não altera o banco.
  def time_values_must_be_valid
    %i[starts_at ends_at].each do |attribute|
      value = public_send(attribute)
      next if value.blank? || valid_time?(value)

      errors.add(attribute, :invalid)
    end
  end

  ##
  # Validação: o turno tem que terminar depois de começar.
  #
  # Não recebe argumentos. Acrescenta um erro em `ends_at`; não altera o banco.
  def end_must_follow_start
    return unless times_valid?
    return if starts_at < ends_at

    errors.add(:ends_at, "deve ser posterior ao início do turno")
  end

  ##
  # Validação: o turno não pode se sobrepor ao de outra refeição (encostar pode: 14:00 e 14:00).
  #
  # Não recebe argumentos. Acrescenta um erro geral; só lê o banco.
  def must_not_overlap_another_shift
    return unless times_valid?
    return unless other_shifts.any? { |shift| overlaps?(shift) }

    errors.add(:base, "O turno não pode se sobrepor a outra refeição.")
  end

  ##
  # Turnos das outras refeições, já gravados.
  #
  # Não recebe argumentos. Retorna uma consulta de Shift; não altera o banco.
  def other_shifts
    self.class.where.not(id: id).where.not(meal_type: meal_type)
  end

  ##
  # Diz se este turno e outro têm algum horário em comum.
  #
  # Recebe o outro Shift. Retorna `true` ou `false`; sem efeitos colaterais.
  def overlaps?(shift)
    starts_at < shift.ends_at && ends_at > shift.starts_at
  end

  ##
  # Diz se o início e o fim são horários válidos.
  #
  # Não recebe argumentos. Retorna `true` ou `false`; sem efeitos colaterais.
  def times_valid?
    valid_time?(starts_at) && valid_time?(ends_at)
  end

  ##
  # Diz se um valor é um horário: texto HH:MM ou algo com hora e minuto.
  #
  # Recebe o valor. Retorna `true` ou `false`; sem efeitos colaterais.
  def valid_time?(value)
    return TIME_FORMAT.match?(value) if value.is_a?(String)

    value.respond_to?(:hour) && value.respond_to?(:min)
  end
end
