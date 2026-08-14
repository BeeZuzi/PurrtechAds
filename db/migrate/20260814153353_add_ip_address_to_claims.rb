class AddIpAddressToClaims < ActiveRecord::Migration[8.1]
  def change
    add_column :claims, :ip_address, :string
    add_index :claims, :ip_address
  end
end
