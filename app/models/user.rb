class User < ApplicationRecord
  has_secure_password
  has_many :servers, dependent: :destroy
  has_many :contract_requests, dependent: :destroy

  ROLES = %w[user server_owner approver admin superadmin].freeze
  enum :role, ROLES.index_with(&:itself), default: "user", validate: true

  before_save { self.email = email.downcase.strip }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" }

  validates :minecraft_nick, presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 16 },
            format: { with: /\A\w+\z/, message: "can only contain letters, numbers and underscores" }

  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :password, confirmation: true, if: -> { new_record? }
end
