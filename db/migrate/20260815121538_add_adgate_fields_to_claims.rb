class AddAdgateFieldsToClaims < ActiveRecord::Migration[8.1]
  def change
    add_column :claims, :external_id, :string
    add_column :claims, :revenue_cents, :integer
    add_column :claims, :source, :string, null: false, default: "simulated"

    add_index :claims, :external_id, unique: true
  end
end
