require "test_helper"

class Admin::PayoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
  end

  def earn(reward_cents, age: 40.days)
    @server.claims.create!(user: users(:player), status: "redeemed", source: "adgate", ip_address: "1.1.1.1",
                           revenue_cents: 50, reward_cents: reward_cents, watched_at: age.ago)
  end

  test "superadmin can view payouts" do
    sign_in_as(users(:superadmin))
    earn(5000)
    get admin_payouts_url
    assert_response :success
  end

  test "a regular admin is redirected away from payouts" do
    sign_in_as(users(:admin))
    get admin_payouts_url
    assert_redirected_to admin_root_url
  end

  test "issuing a payout reserves the server's balance" do
    sign_in_as(users(:superadmin))
    earn(1000)

    assert_difference "Payout.count", 1 do
      post admin_payouts_url(server_id: @server.id)
    end

    assert_equal 0, @server.reload.balance_cents
    assert_equal 1000, Payout.last.amount_cents
  end

  test "cannot issue a payout with no balance" do
    sign_in_as(users(:superadmin))

    assert_no_difference "Payout.count" do
      post admin_payouts_url(server_id: @server.id)
    end
    assert_redirected_to admin_payouts_url
  end

  test "cannot issue a payout without an approved contract" do
    sign_in_as(users(:superadmin))
    earn(5000)
    contract_requests(:approved_request).update!(status: "rejected")

    assert_no_difference "Payout.count" do
      post admin_payouts_url(server_id: @server.id)
    end
    assert_match(/no approved contract/, flash[:alert])
  end

  test "mark_paid updates status and paid_at" do
    sign_in_as(users(:superadmin))
    payout = @server.payouts.create!(amount_cents: 1000, currency: "EUR")

    patch mark_paid_admin_payout_url(payout)

    assert payout.reload.paid?
    assert payout.paid_at.present?
  end

  test "mark_failed releases the earnings" do
    sign_in_as(users(:superadmin))
    earn(1000)
    payout = Payout.issue!(@server)

    patch mark_failed_admin_payout_url(payout)

    assert payout.reload.failed?
    assert_equal 1000, @server.reload.balance_cents
  end
end
