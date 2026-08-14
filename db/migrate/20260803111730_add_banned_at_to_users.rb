class AddBannedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :banned_at, :datetime
    add_index :users, :banned_at
  end
end