class AddBannedUntilToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :banned_until, :datetime
  end
end
