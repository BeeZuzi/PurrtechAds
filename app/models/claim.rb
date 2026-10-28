class Claim < ApplicationRecord
  belongs_to :user
  belongs_to :server
  has_many :fraud_flags, dependent: :nullify

  STATUSES = %w[pending redeemed failed expired].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  SOURCES = %w[simulated adgate].freeze
  enum :source, SOURCES.index_with(&:itself), default: "simulated", validate: true, prefix: true

  validates :token, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_nil: true

  before_validation :generate_token, on: :create
  before_validation :set_watch_window, on: :create
  before_create :set_reward

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

  def set_reward
    self.reward_cents ||= PayoutPolicy.reward_cents
  end

  def set_watch_window
    self.watched_at ||= Time.current
    self.expires_at ||= watched_at + 24.hours
  end
end
