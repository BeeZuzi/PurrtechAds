require "test_helper"

class Api::Plugin::ClaimsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
    @player = users(:player)
  end

  test "lists claimable claims for a player by minecraft uuid" do
    claim = @server.claims.create!(user: @player)
    get api_plugin_player_claims_url(uuid: @player.minecraft_uuid), headers: auth_headers(@server)
    assert_response :success

    ids = JSON.parse(response.body).map { |c| c["id"] }
    assert_includes ids, claim.id
  end

  test "excludes claims that belong to a different server" do
    other_server = Server.create!(user: users(:owner), name: "Other", description: "x", status: "approved")
    other_server.claims.create!(user: @player)

    get api_plugin_player_claims_url(uuid: @player.minecraft_uuid), headers: auth_headers(@server)
    assert_equal [], JSON.parse(response.body)
  end

  test "excludes already-redeemed and expired claims" do
    @server.claims.create!(user: @player, status: "redeemed", redeemed_at: Time.current)
    @server.claims.create!(user: @player, expires_at: 1.minute.ago)

    get api_plugin_player_claims_url(uuid: @player.minecraft_uuid), headers: auth_headers(@server)
    assert_equal [], JSON.parse(response.body)
  end

  test "redeem marks a pending claim redeemed" do
    claim = @server.claims.create!(user: @player)
    post api_plugin_redeem_claim_url(claim), headers: auth_headers(@server)

    assert_response :success
    assert claim.reload.redeemed?
    assert claim.redeemed_at.present?
  end

  test "redeem is rejected for an already-redeemed claim" do
    claim = @server.claims.create!(user: @player, status: "redeemed", redeemed_at: Time.current)
    post api_plugin_redeem_claim_url(claim), headers: auth_headers(@server)
    assert_response :unprocessable_entity
  end

  test "fail marks a pending claim failed" do
    claim = @server.claims.create!(user: @player)
    post api_plugin_fail_claim_url(claim), headers: auth_headers(@server)

    assert_response :success
    assert claim.reload.failed?
  end

  test "a server cannot redeem another server's claim" do
    other_server = Server.create!(user: users(:owner), name: "Other", description: "x", status: "approved")
    claim = other_server.claims.create!(user: @player)

    post api_plugin_redeem_claim_url(claim), headers: auth_headers(@server)

    assert_response :not_found
    assert claim.reload.pending?
  end

  private

  def auth_headers(server)
    { "X-Api-Key" => server.api_key, "X-Api-Secret" => server.api_secret }
  end
end
