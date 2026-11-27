# Janela de horário (time-frame) de um turno, de 15 minutos no Figma. O sorteio do FastPass é feito por
# janela, e cada uma pode ter a própria cota de passes.
class Timeframe < ApplicationRecord
  belongs_to :shift
  has_many :fast_pass_enrollments, dependent: :restrict_with_error

  validates :starts_at, :ends_at, presence: true
  validate :must_fit_inside_shift
  validate :end_must_follow_start
  validates :quota, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :quota_within_fastpass_capacity

  ##
  # Cota que vale no sorteio desta janela.
  #
  # Não recebe argumentos. Retorna a cota da janela ou, quando ela não tem uma, a cota padrão do
  # FastPass (FastPassSetting.global). Não altera o banco.
  def effective_quota
    quota || FastPassSetting.global.default_quota
  end

  private

  ##
  # Validação: a cota não pode passar do que as catracas FastPass aguentam a cada 15 minutos.
  #
  # Não recebe argumentos. Acrescenta um erro em `quota`; só lê o banco.
  def quota_within_fastpass_capacity
    return if quota.nil? || quota <= Turnstile.where(fastpass_corridor: true).sum(:capacity)

    errors.add(:quota, "acima da capacidade das catracas FastPass")
  end

  ##
  # Validação: a janela tem que caber dentro do turno da refeição.
  #
  # Não recebe argumentos. Acrescenta um erro geral; não altera o banco.
  def must_fit_inside_shift
    return if shift.blank? || !times_present?
    return if inside_shift?

    errors.add(:base, "O time-frame deve estar dentro do turno da refeição.")
  end

  ##
  # Validação: a janela tem que terminar depois de começar.
  #
  # Não recebe argumentos. Acrescenta um erro em `ends_at`; não altera o banco.
  def end_must_follow_start
    return unless times_present?
    return if ends_at > starts_at

    errors.add(:ends_at, "deve ser posterior ao início do time-frame")
  end

  ##
  # Diz se o início e o fim foram preenchidos.
  #
  # Não recebe argumentos. Retorna `true` ou `false`; sem efeitos colaterais.
  def times_present?
    starts_at.present? && ends_at.present?
  end

  ##
  # Diz se a janela começa e termina dentro do horário do turno.
  #
  # Não recebe argumentos. Retorna `true` ou `false`; sem efeitos colaterais.
  def inside_shift?
    starts_at >= shift.starts_at && ends_at <= shift.ends_at
  end
end
