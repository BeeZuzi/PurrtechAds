require "test_helper"

class Admin::ServersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
  end

  def view(status: "redeemed", age: 40.days, revenue: 50)
    @server.claims.create!(user: users(:player), status: status, source: "adgate", ip_address: "1.1.1.1",
                           revenue_cents: revenue, reward_cents: 5, watched_at: age.ago)
  end

  test "the list shows views and the amount each server should get" do
    3.times { view }
    view(age: 2.days)
    view(status: "pending")
    sign_in_as(users(:admin))

    get admin_servers_url

    assert_response :success
    assert_match "SkyBlock Prague", response.body
    assert_select "tbody tr", minimum: 1
    # 5 confirmed views, 4 redeemed: 4 x 0.05 = 0.20 owed, 3 x 0.05 = 0.15 ready
    assert_match "0.20 #{PayoutPolicy.currency}", response.body
    assert_match "0.15 #{PayoutPolicy.currency}", response.body
  end

  test "each row opens the server detail, so there is no separate Detail button" do
    sign_in_as(users(:admin))

    get admin_servers_url

    assert_select "tr[data-controller='row-link'][data-row-link-url-value='#{admin_server_path(@server)}']"
    assert_select "tbody a", text: "Detail", count: 0
  end

  test "views that were never confirmed by the ad network are not counted" do
    @server.claims.create!(user: users(:player), status: "redeemed", ip_address: "1.1.1.1")

    assert_equal 0, @server.confirmed_views_count
    assert_equal 0, @server.owed_cents
  end

  test "pending and paid payouts are shown separately" do
    @server.payouts.create!(amount_cents: 300, currency: "EUR")
    @server.payouts.create!(amount_cents: 700, currency: "EUR", status: "paid", paid_at: Time.current)

    assert_equal 300, @server.pending_payout_cents
    assert_equal 700, @server.paid_out_cents
  end

  test "the server detail has a payout table with date, amount and paid status" do
    paid = @server.payouts.create!(amount_cents: 700, currency: "EUR", status: "paid", paid_at: Time.zone.local(2026, 10, 20, 9, 30))
    @server.payouts.create!(amount_cents: 300, currency: "EUR")
    view
    @server.claims.update_all(payout_id: paid.id)
    sign_in_as(users(:admin))

    get admin_server_url(@server)

    assert_select "table.sheet tbody tr", 2
    assert_select "table.sheet", text: /7\.00 EUR/
    assert_select "table.sheet", text: /20\.10\.2026 09:30/
    assert_select "table.sheet", text: /Vyplaceno celkem/
    assert_select "table.sheet tbody tr.sheet-paid .num", text: "1"
  end

  test "the server detail shows the same summary" do
    view
    sign_in_as(users(:admin))

    get admin_server_url(@server)

    assert_response :success
    assert_match "Zhlédnuté reklamy", response.body
  end
end
