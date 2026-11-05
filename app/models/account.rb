class Account < ApplicationRecord
  # Admin e operador: 7 dígitos
  STAFF_USER_FORMAT = /\A\d{7}\z/
  # Estudante: AA SS DDDDD (ano 00–26, semestre 10 ou 20, 5 dígitos).
  STUDENT_USER_FORMAT = /\A(?:[01]\d|2[0-6])(?:10|20)\d{5}\z/

  has_secure_password
  has_one :student, foreign_key: :user, inverse_of: :account
  after_create :create_student!, if: -> { role == "student" }

  validates :user, presence: true
  validates :name, presence: true
  validates :role, presence: true
  validates :user, uniqueness: true
  validates :role, inclusion: { in: %w[admin operator student] }
  validates :user, format: { with: STAFF_USER_FORMAT }, if: -> { role.in?(%w[admin operator]) }
  validates :user, format: { with: STUDENT_USER_FORMAT }, if: -> { role == "student" }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def self.user_format_for(role)
    role == "student" ? STUDENT_USER_FORMAT : STAFF_USER_FORMAT
  end
end
