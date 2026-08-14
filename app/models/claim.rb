class Claim < ApplicationRecord
  belongs_to :user
  belongs_to :server
  has_many :fraud_flags, dependent: :nullify

  STATUSES = %w[pending redeemed failed expired].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create
  before_validation :set_watch_window, on: :create

  scope :claimable, -> { pending.where("expires_at > ?", Time.current) }

  def expired?
    pending? && expires_at <= Time.current
  end

  def claimable?
    pending? && expires_at > Time.current
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(20)
  end

  def set_watch_window
    self.watched_at ||= Time.current
    self.expires_at ||= watched_at + 24.hours
  end
end
