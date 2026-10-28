class ContractRequest < ApplicationRecord
  belongs_to :user
  belongs_to :server

  ENTITY_TYPES = %w[individual sole_trader company].freeze
  CURRENCIES = %w[USD EUR GBP CZK PLN CAD AUD JPY].freeze
  PAYOUT_METHODS = %w[bank_transfer paypal stripe crypto].freeze
  STATUSES = %w[pending approved rejected].freeze

  # Bump when the partner terms change, so each contract shows which version was accepted.
  PARTNER_TERMS_VERSION = "2026-10-28".freeze

  enum :entity_type, ENTITY_TYPES.index_with(&:itself), validate: true, prefix: true
  enum :preferred_currency, CURRENCIES.index_with(&:itself), default: "EUR", validate: true
  enum :payout_method, PAYOUT_METHODS.index_with(&:itself), validate: true, prefix: true
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :legal_name, presence: true, length: { maximum: 150 }
  validates :country_code, presence: true, length: { is: 2 }
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tax_id, length: { maximum: 40 }
  validates :registered_address, presence: true, length: { maximum: 300 }
  validates :message, length: { maximum: 1000 }
  validates :partner_terms, acceptance: { allow_nil: false }, on: :create

  def partner_terms_accepted?
    terms_accepted_at.present? && terms_version.present?
  end

  # Records the click-through acceptance: when, which version and from where.
  def accept_partner_terms!(ip:)
    assign_attributes(terms_accepted_at: Time.current, terms_version: PARTNER_TERMS_VERSION, terms_accepted_ip: ip)
  end

  # Plain-text copy of the recipient's details, stored on each payout.
  def payout_snapshot
    [
      "#{legal_name} (#{entity_type.humanize}, #{country_name})",
      ("Tax ID: #{tax_id}" if tax_id.present?),
      registered_address,
      "Contact: #{contact_email}",
      "Method: #{payout_method.humanize}, currency: #{preferred_currency}",
      "Partner terms #{terms_version} accepted #{terms_accepted_at&.iso8601} from #{terms_accepted_ip}"
    ].compact.join("\n")
  end

  def country_name
    ISO3166::Country[country_code]&.common_name || country_code
  end
end
