class Payout < ApplicationRecord
  belongs_to :server

  STATUSES = %w[pending paid failed].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :currency, presence: true

  def amount
    amount_cents / 100.0
  end

  def self.format_cents(cents, currency = "USD")
    "#{'%.2f' % (cents / 100.0)} #{currency}"
  end
end
