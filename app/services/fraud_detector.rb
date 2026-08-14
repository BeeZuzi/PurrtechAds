# Runs after a claim is created and looks for signals too ambiguous to
# hard-block automatically (e.g. shared households/schools use the same IP
# legitimately) — raises a FraudFlag for a human to review instead.
class FraudDetector
  SHARED_IP_WINDOW = 24.hours
  SHARED_IP_ACCOUNT_THRESHOLD = 3

  def initialize(claim)
    @claim = claim
  end

  def call
    flag_shared_ip! if shared_ip_multi_account?
  end

  private

  attr_reader :claim

  def shared_ip_multi_account?
    claim.ip_address.present? && distinct_user_ids.size >= SHARED_IP_ACCOUNT_THRESHOLD
  end

  def distinct_user_ids
    Claim.where(ip_address: claim.ip_address)
         .where("watched_at > ?", SHARED_IP_WINDOW.ago)
         .distinct
         .pluck(:user_id)
  end

  def flag_shared_ip!
    return if FraudFlag.exists?(claim: claim, reason: "shared_ip_multi_account")

    FraudFlag.create!(
      user: claim.user,
      claim: claim,
      reason: "shared_ip_multi_account",
      details: "#{distinct_user_ids.size} accounts claimed rewards from IP #{claim.ip_address} within #{SHARED_IP_WINDOW.inspect}."
    )
  end
end
