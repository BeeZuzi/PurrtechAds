require "test_helper"

class Admin::PayoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
  end

  test "superadmin can view payouts" do
    sign_in_as(users(:superadmin))
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
    5.times { @server.claims.create!(user: users(:player), status: "redeemed", ip_address: "1.1.1.1") }

    assert_difference "Payout.count", 1 do
      post admin_payouts_url(server_id: @server.id)
    end

    assert_equal 0, @server.reload.balance_cents
    assert_equal 5, Payout.last.amount_cents
  end

  test "cannot issue a payout with no balance" do
    sign_in_as(users(:superadmin))

    assert_no_difference "Payout.count" do
      post admin_payouts_url(server_id: @server.id)
    end
  end

  test "mark_paid updates status and paid_at" do
    sign_in_as(users(:superadmin))
    payout = @server.payouts.create!(amount_cents: 10, currency: "USD")

    patch mark_paid_admin_payout_url(payout)

    assert payout.reload.paid?
    assert payout.paid_at.present?
  end
end
