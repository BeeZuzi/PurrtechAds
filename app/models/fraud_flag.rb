class FraudFlag < ApplicationRecord
  belongs_to :user
  belongs_to :claim, optional: true

  REASONS = %w[shared_ip_multi_account].freeze
  STATUSES = %w[pending reviewing confirmed dismissed].freeze

  enum :reason, REASONS.index_with(&:itself), validate: true
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :details, length: { maximum: 500 }
end
