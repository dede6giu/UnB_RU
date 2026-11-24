class Access < ApplicationRecord
  STATUSES = %w[allowed blocked].freeze
  REASONS = %w[no_balance not_found].freeze

  belongs_to :student, optional: true
  belongs_to :restaurant
  belongs_to :turnstile

  validates :registration, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :reason, inclusion: { in: REASONS }, allow_nil: true
  validate :reason_matches_status

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  scope :for_restaurant, ->(id) { id.present? ? where(restaurant_id: id) : all }
  scope :for_turnstile, ->(id) { id.present? ? where(turnstile_id: id) : all }

  private

  ##
  # Valida a coerência entre `status` e `reason`.
  #
  # Não recebe argumentos. Não retorna valor útil.
  # Adiciona erro em `reason` quando o acesso é bloqueado sem motivo ou liberado com motivo.
  def reason_matches_status
    errors.add(:reason, "obrigatório para bloqueio") if status == "blocked" && reason.blank?
    errors.add(:reason, "deve ser vazio para liberação") if status == "allowed" && reason.present?
  end
end
