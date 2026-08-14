class CreateClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :claims do |t|
      t.references :user, null: false, foreign_key: true
      t.references :server, null: false, foreign_key: true
      t.string :token, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :watched_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :redeemed_at
      t.datetime :failed_at

      t.timestamps
    end

    add_index :claims, :token, unique: true
    add_index :claims, :status
  end
end
