class CreateFraudFlags < ActiveRecord::Migration[8.1]
  def change
    create_table :fraud_flags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :claim, foreign_key: true
      t.string :reason, null: false
      t.string :status, null: false, default: "pending"
      t.text :details

      t.timestamps
    end

    add_index :fraud_flags, :status
  end
end
