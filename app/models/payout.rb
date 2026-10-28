class Payout < ApplicationRecord
  belongs_to :server
  belongs_to :contract_request, optional: true
  has_many :claims, dependent: :nullify

  STATUSES = %w[pending paid failed].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :currency, presence: true

  # Raised when a server can't be paid right now. `reason` is one of
  # :no_contract, :no_terms, :below_minimum or :claims_changed.
  class NotEligible < StandardError
    attr_reader :reason

    def initialize(reason)
      @reason = reason
      super(reason.to_s)
    end
  end

  # Pays out everything the server has earned past the hold period: locks those
  # claims to the new payout, so the same earnings can never be paid twice, and
  # keeps a copy of the recipient's details as they were at payment time.
  def self.issue!(server)
    transaction do
      contract = server.payout_contract
      claims = server.payable_claims.to_a
      cents = claims.sum(&:reward_cents)
      reason = server.payout_blocker(contract: contract, cents: cents)
      raise NotEligible, reason if reason

      payout = server.payouts.create!(
        amount_cents: cents,
        currency: PayoutPolicy.currency,
        contract_request: contract,
        recipient_snapshot: contract.payout_snapshot
      )
      linked = Claim.where(id: claims.map(&:id), payout_id: nil).update_all(payout_id: payout.id)
      raise NotEligible, :claims_changed unless linked == claims.size

      payout
    end
  end

  def mark_paid!
    return false unless pending?

    update!(status: "paid", paid_at: Time.current)
  end

  # A failed payout hands its claims back, so they go into the next payout.
  def mark_failed!
    return false unless pending?

    transaction do
      claims.update_all(payout_id: nil)
      update!(status: "failed")
    end
  end

  def amount
    amount_cents / 100.0
  end

  def self.format_cents(cents, currency = PayoutPolicy.currency)
    "#{'%.2f' % (cents / 100.0)} #{currency}"
  end
end
