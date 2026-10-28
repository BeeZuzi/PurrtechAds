# Business rules for paying servers. Every value can be overridden with an
# environment variable, so the numbers can change without a deploy.
#
# A server earns a fixed reward for every ad view the ad network confirmed.
# The reward is stored on the claim when it is created (Claim#reward_cents), so
# changing it only affects later views. Claim#revenue_cents (what the ad network
# pays us) is never shown to servers; it only proves the view was confirmed and
# lets the admin see the margin.
module PayoutPolicy
  module_function

  # Fixed reward per confirmed ad view, in cents of the payout currency.
  def reward_cents
    Integer(ENV.fetch("PAYOUT_REWARD_CENTS", 5))
  end

  # Days a claim waits before it counts, so ad-network reversals and fraud
  # reviews have time to land before money leaves.
  def hold_days
    Integer(ENV.fetch("PAYOUT_HOLD_DAYS", 30))
  end

  # Smaller balances roll over to the next payout.
  def minimum_cents
    Integer(ENV.fetch("PAYOUT_MINIMUM_CENTS", 1000))
  end

  def currency
    ENV.fetch("PAYOUT_CURRENCY", "EUR")
  end

  # Multiplier from the ad network's currency (revenue_cents) to the payout
  # currency. Only used to show our margin in the admin. Leave at 1 when both
  # are the same.
  def revenue_rate
    BigDecimal(ENV.fetch("PAYOUT_REVENUE_RATE", "1"))
  end

  def revenue_in_payout_currency(revenue_cents)
    (revenue_cents * revenue_rate).floor
  end
end
