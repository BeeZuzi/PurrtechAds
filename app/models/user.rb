# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  generates_token_for :email_confirmation, expires_in: 1.day do
    email
  end

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest.last(10)
  end

  has_many :servers, dependent: :destroy
  has_many :contract_requests, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :fraud_flags, dependent: :destroy

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

  validates :minecraft_uuid, uniqueness: true, allow_blank: true,
            format: { with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i,
                       message: "must be a valid Minecraft UUID (e.g. 069a79f4-44e9-4726-a5be-fca90e38aaf5)" }

  def can_approve_servers?
    approver? || admin? || superadmin?
  end

  def can_manage_users?
    admin? || superadmin?
  end

  def can_access_admin?
    admin? || superadmin?
  end

  def banned?
    banned_at.present? && (banned_until.nil? || banned_until > Time.current)
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end

  def send_confirmation_email
    UserMailer.confirmation_email(self).deliver_later
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_later
  end
end
