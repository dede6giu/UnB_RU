class Account < ApplicationRecord
  # Admin e operador: 7 dígitos quaisquer.
  STAFF_USER_FORMAT = /\A\d{7}\z/
  # Estudante: AA SS DDDDD (ano 00–26, semestre 10 ou 20, 5 dígitos).
  STUDENT_USER_FORMAT = /\A(?:[01]\d|2[0-6])(?:10|20)\d{5}\z/

  has_secure_password validations: false
  has_one :student, foreign_key: :user, inverse_of: :account
  after_create :create_student, if: -> { role == "student" }

  validates :user, presence: { message: "Matrícula não pode ser vazio." }
  validates :name, presence: { message: "Nome não pode ser vazio." }
  validates :role, presence: { message: "Cargo não pode ser vazio." }
  validates :user, uniqueness: { message: "Matrícula já registrada." }
  validates :role, inclusion: { in: %w[admin operator student], message: "Cargo deve ser admin, operator ou student." }
  validates :user, format: { with: STAFF_USER_FORMAT, message: "Matrícula inválida." }, if: -> { role.in?(%w[admin operator]) }
  validates :user, format: { with: STUDENT_USER_FORMAT, message: "Matrícula inválida." }, if: -> { role == "student" }
  validates :password, length: { minimum: 8, too_short: "Senha deve ter 8 ou mais caracteres." }
  validates :password, presence: { message: "Senha não pode ser vazio." }

  def self.user_format_for(role)
    role == "student" ? STUDENT_USER_FORMAT : STAFF_USER_FORMAT
  end

  def create_student
    student_new = Student.create(user: user, balance_cents: 0)
    raise "Couldn't create account." unless student_new.save
  end
end
