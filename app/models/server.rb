class Server < ApplicationRecord
  belongs_to :user
  has_many :contract_requests, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :payouts, dependent: :destroy

  STATUSES = %w[pending approved rejected suspended].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  before_create :generate_api_credentials
  after_create :promote_owner_to_server_owner

  validates :name, presence: true, length: { minimum: 3, maximum: 40 }
  validates :description, length: { maximum: 500 }

  FLAGS_BLOCKING_PAYOUT = %w[pending reviewing confirmed].freeze

  # Redeemed claims the ad network confirmed (they carry its revenue) that are
  # past the hold period, not under fraud review and not already in a payout.
  def payable_claims
    unpaid_confirmed_claims
      .where("claims.watched_at <= ?", PayoutPolicy.hold_days.days.ago)
      .where.not(id: FraudFlag.where(status: FLAGS_BLOCKING_PAYOUT).where.not(claim_id: nil).select(:claim_id))
  end

  # What the server can be paid right now.
  def balance_cents
    payable_claims.sum(:reward_cents)
  end

  # Earned but not payable yet: still inside the hold period or under review.
  def held_cents
    unpaid_confirmed_claims.sum(:reward_cents) - balance_cents
  end

  # Ad views the ad network confirmed, and how many of them the player already collected in game.
  def confirmed_views_count
    claims.where.not(revenue_cents: nil).count
  end

  def redeemed_views_count
    claims.redeemed.where.not(revenue_cents: nil).count
  end

  # The newest payout that was not a failure; the point owners count "since the last payout" from.
  def last_payout
    payouts.where.not(status: "failed").order(created_at: :desc).first
  end

  def views_since_last_payout
    since = last_payout&.created_at
    views = claims.where.not(revenue_cents: nil)
    since ? views.where("claims.watched_at > ?", since).count : views.count
  end

  # Everything earned and not yet in a payout (ready to pay + still on hold).
  def owed_cents
    balance_cents + held_cents
  end

  # In payout requests that wait for the money to be sent.
  def pending_payout_cents
    payouts.pending.sum(:amount_cents)
  end

  def paid_out_cents
    payouts.paid.sum(:amount_cents)
  end

  # What the ad network pays us for the unpaid claims, in the payout currency.
  # Compare with balance_cents + held_cents to see our margin.
  def unpaid_revenue_cents
    PayoutPolicy.revenue_in_payout_currency(unpaid_confirmed_claims.sum(:revenue_cents))
  end

  # The latest approved contract; payouts go to the details in it.
  def payout_contract
    contract_requests.approved.order(:created_at).last
  end

  # Why this server can't be paid, or nil when it can.
  def payout_blocker(contract: payout_contract, cents: balance_cents)
    return :no_contract if contract.nil?
    return :no_terms unless contract.partner_terms_accepted?
    return :below_minimum if cents < PayoutPolicy.minimum_cents

    nil
  end

  private

  def unpaid_confirmed_claims
    claims.redeemed.where(payout_id: nil).where.not(revenue_cents: nil)
  end

  def promote_owner_to_server_owner
    user.update(role: "server_owner") if user.user?
  end

  def generate_api_credentials
    self.api_key ||= SecureRandom.hex(16)
    self.api_secret ||= SecureRandom.hex(32)
  end
end
