class AddRequestedByToPayouts < ActiveRecord::Migration[8.1]
  def change
    add_reference :payouts, :requested_by, foreign_key: { to_table: :users }
  end
end
