class CreateServers < ActiveRecord::Migration[7.1]
  def change
    create_table :servers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.string :api_key, null: false
      t.string :api_secret, null: false

      t.timestamps
    end

    add_index :servers, :name
    add_index :servers, :api_key, unique: true
  end
end
