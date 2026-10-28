class AddPartnerTermsAcceptanceToContractRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :contract_requests, :terms_accepted_at, :datetime
    add_column :contract_requests, :terms_version, :string
    add_column :contract_requests, :terms_accepted_ip, :string

    change_column_default :contract_requests, :preferred_currency, from: "USD", to: "EUR"
  end
end
