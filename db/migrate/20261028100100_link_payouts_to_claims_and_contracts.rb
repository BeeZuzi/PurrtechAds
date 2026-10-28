class LinkPayoutsToClaimsAndContracts < ActiveRecord::Migration[8.1]
  def change
    add_reference :claims, :payout, foreign_key: true
    add_reference :payouts, :contract_request, foreign_key: true
    add_column :payouts, :recipient_snapshot, :text

    change_column_default :payouts, :currency, from: "USD", to: "EUR"
  end
end
