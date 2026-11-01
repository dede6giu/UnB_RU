class Account < ApplicationRecord
  has_secure_password
  validates :user, presence: true
  validates :name, presence: true
  validates :role, presence: true
  validates :user, uniqueness: true
  validates :role, inclusion: { in: %w[admin operator student] }
end
