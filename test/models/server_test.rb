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

  test "earned_cents counts only redeemed claims at the placeholder rate" do
    server = servers(:approved_server)
    3.times { server.claims.create!(user: users(:player), status: "redeemed", ip_address: "1.1.1.1") }
    server.claims.create!(user: users(:player), status: "pending", ip_address: "1.1.1.1")

    assert_equal 3 * Server::RATE_PER_CLAIM_CENTS, server.earned_cents
  end

  test "balance_cents reserves pending payouts and releases failed ones" do
    server = servers(:approved_server)
    5.times { server.claims.create!(user: users(:player), status: "redeemed", ip_address: "1.1.1.1") }
    assert_equal 5, server.balance_cents

    payout = server.payouts.create!(amount_cents: 5, currency: "USD")
    assert_equal 0, server.reload.balance_cents

    payout.update!(status: "failed")
    assert_equal 5, server.reload.balance_cents
  end
end
