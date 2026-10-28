require "test_helper"

class PayoutTest < ActiveSupport::TestCase
  setup do
    @server = servers(:approved_server)
  end

  def earn(reward_cents, age: 40.days)
    @server.claims.create!(user: users(:player), status: "redeemed", source: "adgate", ip_address: "1.1.1.1",
                           revenue_cents: 50, reward_cents: reward_cents, watched_at: age.ago)
  end

  test "requires a positive amount" do
    payout = Payout.new(server: @server, amount_cents: 0)
    assert_not payout.valid?
  end

  test "format_cents renders amount and currency" do
    assert_equal "1.23 USD", Payout.format_cents(123, "USD")
    assert_equal "1.23 #{PayoutPolicy.currency}", Payout.format_cents(123)
  end

  test "issue! pays the server's share, links the claims and snapshots the recipient" do
    claims = [ earn(600), earn(400) ]

    payout = Payout.issue!(@server)

    assert_equal 1000, payout.amount_cents
    assert_equal PayoutPolicy.currency, payout.currency
    assert_equal contract_requests(:approved_request), payout.contract_request
    assert_includes payout.recipient_snapshot, "Jane Doe s.r.o."
    assert_equal claims.map(&:id).sort, payout.claims.pluck(:id).sort
    assert_equal 0, @server.reload.balance_cents
  end

  test "issue! can't pay the same earnings twice" do
    earn(1000)
    Payout.issue!(@server)

    error = assert_raises(Payout::NotEligible) { Payout.issue!(@server) }
    assert_equal :below_minimum, error.reason
  end

  test "issue! refuses a balance below the minimum" do
    earn(999)

    error = assert_raises(Payout::NotEligible) { Payout.issue!(@server) }
    assert_equal :below_minimum, error.reason
    assert_equal 999, @server.reload.balance_cents
  end

  test "issue! needs an approved contract with accepted terms" do
    earn(5000)
    contract_requests(:approved_request).update!(status: "pending")
    assert_equal :no_contract, assert_raises(Payout::NotEligible) { Payout.issue!(@server) }.reason

    contract_requests(:approved_request).update!(status: "approved", terms_accepted_at: nil)
    assert_equal :no_terms, assert_raises(Payout::NotEligible) { Payout.issue!(@server) }.reason
  end

  test "mark_failed! gives the claims back so they go into the next payout" do
    earn(1000)
    payout = Payout.issue!(@server)

    assert payout.mark_failed!

    assert payout.reload.failed?
    assert_equal 1000, @server.reload.balance_cents
  end

  test "a paid payout can't be failed or paid again" do
    earn(1000)
    payout = Payout.issue!(@server)
    payout.mark_paid!

    assert_not payout.mark_failed!
    assert_not payout.mark_paid!
    assert payout.reload.paid?
  end
end
