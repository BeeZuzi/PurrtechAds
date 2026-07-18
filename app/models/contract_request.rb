class ContractRequest < ApplicationRecord
  belongs_to :user
  belongs_to :server

  ENTITY_TYPES = %w[individual sole_trader company].freeze
  CURRENCIES = %w[USD EUR GBP CZK PLN CAD AUD JPY].freeze
  PAYOUT_METHODS = %w[bank_transfer paypal stripe crypto].freeze
  STATUSES = %w[pending approved rejected].freeze

  enum :entity_type, ENTITY_TYPES.index_with(&:itself), validate: true, prefix: true
  enum :preferred_currency, CURRENCIES.index_with(&:itself), default: "USD", validate: true
  enum :payout_method, PAYOUT_METHODS.index_with(&:itself), validate: true, prefix: true
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :legal_name, presence: true, length: { maximum: 150 }
  validates :country_code, presence: true, length: { is: 2 }
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tax_id, length: { maximum: 40 }
  validates :registered_address, presence: true, length: { maximum: 300 }
  validates :message, length: { maximum: 1000 }

  def country_name
    ISO3166::Country[country_code]&.common_name || country_code
  end
end