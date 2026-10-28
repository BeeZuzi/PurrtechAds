class AddRewardCentsToClaims < ActiveRecord::Migration[8.1]
  def up
    add_column :claims, :reward_cents, :integer

    # Claims that already exist get the current reward, so nothing earned so far is lost.
    execute "UPDATE claims SET reward_cents = #{Integer(ENV.fetch("PAYOUT_REWARD_CENTS", 5))} WHERE source = 'adgate'"
  end

  def down
    remove_column :claims, :reward_cents
  end
end
