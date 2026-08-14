class AddMinecraftUuidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :minecraft_uuid, :string
    add_index :users, :minecraft_uuid, unique: true
  end
end
