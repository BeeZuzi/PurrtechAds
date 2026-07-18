class CreateContractRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :contract_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :server, null: false, foreign_key: true

      t.string :entity_type, null: false
      t.string :legal_name, null: false
      t.string :country_code, null: false
      t.string :tax_id
      t.text :registered_address

      t.string :contact_email, null: false
      t.string :phone

      t.string :preferred_currency, null: false, default: "USD"
      t.string :payout_method, null: false

      t.text :message
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
