require "test_helper"

class ServerTest < ActiveSupport::TestCase
  test "generates api credentials on create" do
    server = Server.create!(user: users(:owner), name: "New Server", description: "desc")
    assert server.api_key.present?
    assert server.api_secret.present?
  end

  test "promotes a plain user to server_owner on first server" do
    user = User.create!(email: "freshowner@example.com", minecraft_nick: "FreshOwner",
                         password: "password123", password_confirmation: "password123")
    assert_equal "user", user.role

    user.servers.create!(name: "Their Server", description: "desc")

    assert_equal "server_owner", user.reload.role
  end

  def redeemed_claim(server, reward_cents: 5, age: 40.days, **attrs)
    server.claims.create!(user: users(:player), status: "redeemed", source: "adgate", ip_address: "1.1.1.1",
                          revenue_cents: 20, reward_cents: reward_cents, watched_at: age.ago, **attrs)
  end

  test "a claim gets the current fixed reward when it is created" do
    claim = servers(:approved_server).claims.create!(user: users(:player), ip_address: "1.1.1.1")

    assert_equal PayoutPolicy.reward_cents, claim.reward_cents
  end

  test "balance is the fixed reward per confirmed view, after the hold period" do
    server = servers(:approved_server)
    3.times { redeemed_claim(server, reward_cents: 7) }

    assert_equal 21, server.balance_cents
  end

  test "views the ad network did not confirm earn nothing" do
    server = servers(:approved_server)
    server.claims.create!(user: users(:player), status: "redeemed", ip_address: "1.1.1.1")

    assert_equal 0, server.balance_cents
    assert_equal 0, server.held_cents
  end

  test "recent claims are held until the hold period passes" do
    server = servers(:approved_server)
    redeemed_claim(server, reward_cents: 9, age: 2.days)

    assert_equal 0, server.balance_cents
    assert_equal 9, server.held_cents
  end

  test "pending and failed claims earn nothing" do
    server = servers(:approved_server)
    redeemed_claim(server, status: "pending")
    redeemed_claim(server, status: "failed")

    assert_equal 0, server.balance_cents
    assert_equal 0, server.held_cents
  end

  test "a claim under fraud review is held; a dismissed flag releases it" do
    server = servers(:approved_server)
    claim = redeemed_claim(server, reward_cents: 9)
    flag = FraudFlag.create!(user: users(:player), claim: claim, reason: "shared_ip_multi_account")

    assert_equal 0, server.balance_cents
    assert_equal 9, server.held_cents

    flag.update!(status: "dismissed")
    assert_equal 9, server.balance_cents
  end

  test "claims already in a payout do not count again" do
    server = servers(:approved_server)
    claim = redeemed_claim(server, reward_cents: 9)
    payout = server.payouts.create!(amount_cents: 9, currency: "EUR")
    claim.update!(payout_id: payout.id)

    assert_equal 0, server.balance_cents
  end

  test "unpaid_revenue_cents shows what the ad network pays us, for the margin" do
    server = servers(:approved_server)
    2.times { redeemed_claim(server, reward_cents: 5) }

    assert_equal 40, server.unpaid_revenue_cents
    assert_equal 30, server.unpaid_revenue_cents - server.balance_cents - server.held_cents
  end

  test "payout_blocker reports a missing contract, missing terms or a low balance" do
    server = servers(:approved_server)
    contract = contract_requests(:approved_request)

    assert_equal :no_contract, server.payout_blocker(contract: nil, cents: 5000)
    assert_equal :no_terms, server.payout_blocker(contract: ContractRequest.new, cents: 5000)
    assert_equal :below_minimum, server.payout_blocker(contract: contract, cents: PayoutPolicy.minimum_cents - 1)
    assert_nil server.payout_blocker(contract: contract, cents: PayoutPolicy.minimum_cents)
  end
end
