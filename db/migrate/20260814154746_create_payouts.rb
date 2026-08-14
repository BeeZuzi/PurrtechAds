class CreatePayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :payouts do |t|
      t.references :server, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "USD"
      t.string :status, null: false, default: "pending"
      t.datetime :paid_at
      t.text :notes

      t.timestamps
    end

    add_index :payouts, :status
  end
end
