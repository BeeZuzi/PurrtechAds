require "test_helper"

class ServerPayoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
  end

  def earn(reward_cents, age: 40.days)
    @server.claims.create!(user: users(:player), status: "redeemed", source: "adgate", ip_address: "1.1.1.1",
                           revenue_cents: 50, reward_cents: reward_cents, watched_at: age.ago)
  end

  test "the owner sees the balance and a request button when payout is possible" do
    earn(1500)
    sign_in_as(users(:owner))

    get server_payouts_url(@server)

    assert_response :success
    assert_select "form[action='#{server_payouts_path(@server)}'] button, form[action='#{server_payouts_path(@server)}'] input[type=submit]"
  end

  test "the owner sees why payout is not possible yet" do
    earn(100)
    sign_in_as(users(:owner))

    get server_payouts_url(@server)

    assert_response :success
    assert_select "form[action='#{server_payouts_path(@server)}']", count: 0
    assert_match Payout.format_cents(PayoutPolicy.minimum_cents, PayoutPolicy.currency), response.body
  end

  test "requesting a payout creates a pending payout recorded as requested by the owner" do
    earn(1500)
    sign_in_as(users(:owner))

    assert_difference "Payout.count", 1 do
      post server_payouts_url(@server)
    end

    payout = Payout.last
    assert_equal 1500, payout.amount_cents
    assert_equal users(:owner), payout.requested_by
    assert payout.pending?
    assert_redirected_to server_payouts_url(@server)
  end

  test "a request below the minimum is refused" do
    earn(100)
    sign_in_as(users(:owner))

    assert_no_difference "Payout.count" do
      post server_payouts_url(@server)
    end
    assert flash[:alert].present?
  end

  test "someone else's server can't be viewed or paid out" do
    earn(1500)
    sign_in_as(users(:player))

    get server_payouts_url(@server)
    assert_redirected_to servers_url

    assert_no_difference "Payout.count" do
      post server_payouts_url(@server)
    end
  end

  test "login is required" do
    get server_payouts_url(@server)
    assert_redirected_to root_url
  end

  test "an unapproved server has no payouts page" do
    sign_in_as(users(:owner))
    get server_payouts_url(servers(:pending_server))
    assert_redirected_to servers_url
  end
end
