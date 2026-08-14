class Server < ApplicationRecord
  belongs_to :user
  has_many :contract_requests, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :payouts, dependent: :destroy

  STATUSES = %w[pending approved rejected suspended].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  # Placeholder rate until real ad revenue replaces it — see FraudDetector-style
  # services once an actual ad network is wired in.
  RATE_PER_CLAIM_CENTS = 1

  before_create :generate_api_credentials
  after_create :promote_owner_to_server_owner

  validates :name, presence: true, length: { minimum: 3, maximum: 40 }
  validates :description, length: { maximum: 500 }

  def earned_cents
    claims.redeemed.count * RATE_PER_CLAIM_CENTS
  end

  # Pending payouts already reserve their share of the balance so a second
  # payout can't be issued against the same earnings while the first is
  # still in flight — only a failed payout releases it again.
  def committed_cents
    payouts.where.not(status: "failed").sum(:amount_cents)
  end

  def balance_cents
    earned_cents - committed_cents
  end

  private

  def promote_owner_to_server_owner
    user.update(role: "server_owner") if user.user?
  end

  def generate_api_credentials
    self.api_key ||= SecureRandom.hex(16)
    self.api_secret ||= SecureRandom.hex(32)
  end
end
