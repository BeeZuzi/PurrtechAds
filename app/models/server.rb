class Server < ApplicationRecord
  belongs_to :user
  has_one :contract_request, dependent: :destroy

  STATUSES = %w[pending approved rejected suspended].freeze
  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  before_create :generate_api_credentials
  after_create :promote_owner_to_server_owner

  validates :name, presence: true, length: { minimum: 3, maximum: 40 }
  validates :description, length: { maximum: 500 }

  private

  def promote_owner_to_server_owner
    user.update(role: "server_owner") if user.user?
  end

  def generate_api_credentials
    self.api_key ||= SecureRandom.hex(16)
    self.api_secret ||= SecureRandom.hex(32)
  end
end
