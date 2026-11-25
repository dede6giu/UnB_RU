class Access < ApplicationRecord
  STATUSES = %w[allowed blocked].freeze
  REASONS = %w[no_balance not_found].freeze

  belongs_to :student, optional: true
  belongs_to :restaurant
  belongs_to :turnstile
  belongs_to :shift, optional: true

  validates :registration, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :reason, inclusion: { in: REASONS }, allow_nil: true
  validate :reason_matches_status

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  scope :for_restaurant, ->(id) { id.present? ? where(restaurant_id: id) : all }
  scope :for_turnstile, ->(id) { id.present? ? where(turnstile_id: id) : all }

  ##
  # Filtra os acessos de um dia inteiro, no fuso da aplicação.
  #
  # Recebe uma data em ISO 8601 (`"2026-11-25"`), um `Date` ou `nil`.
  # Retorna uma `ActiveRecord::Relation`; data ausente ou inválida não filtra.
  # Não altera o banco de dados.
  def self.for_date(value)
    day = Date.iso8601(value.to_s)
    where(created_at: day.all_day)
  rescue Date::Error
    all
  end

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
