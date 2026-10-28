require "test_helper"

class Postbacks::AdGateControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:player)
    @server = servers(:approved_server)
  end

  test "creates a claim from a valid postback" do
    assert_difference "Claim.count", 1 do
      get postbacks_adgate_url, params: postback_params
    end

    claim = Claim.last
    assert_equal @user, claim.user
    assert_equal @server, claim.server
    assert claim.pending?
    assert claim.source_adgate?
    assert_equal "conv-1", claim.external_id
    assert_equal 150, claim.revenue_cents
    assert_equal "9.8.7.6", claim.ip_address
    assert_response :success
  end

  test "rejects a tampered token" do
    assert_no_difference "Claim.count" do
      get postbacks_adgate_url, params: postback_params.merge(s1: "garbage")
    end
    assert_response :unauthorized
  end

  test "rejects an expired token" do
    stale_token = Rails.application.message_verifier(:adgate_offer).generate(
      { "user_id" => @user.id, "server_id" => @server.id }, expires_in: -1.second
    )

    assert_no_difference "Claim.count" do
      get postbacks_adgate_url, params: postback_params.merge(s1: stale_token)
    end
    assert_response :unauthorized
  end

  test "is idempotent for a repeated conversion id" do
    get postbacks_adgate_url, params: postback_params
    assert_difference "Claim.count", 0 do
      get postbacks_adgate_url, params: postback_params
    end
    assert_response :success
  end

  test "rejects requests from an IP outside the configured allowlist" do
    ENV["ADGATE_POSTBACK_IPS"] = "1.2.3.4"

    assert_no_difference "Claim.count" do
      get postbacks_adgate_url, params: postback_params
    end
    assert_response :unauthorized
  ensure
    ENV.delete("ADGATE_POSTBACK_IPS")
  end

  test "in production a postback is rejected while no IP allowlist is configured" do
    with_required_allowlist do
      assert_no_difference "Claim.count" do
        get postbacks_adgate_url, params: postback_params
      end
      assert_response :unauthorized
    end
  end

  test "in production a postback from an allowlisted IP is accepted" do
    ENV["ADGATE_POSTBACK_IPS"] = "127.0.0.1, 1.2.3.4"

    with_required_allowlist do
      assert_difference "Claim.count", 1 do
        get postbacks_adgate_url, params: postback_params
      end
      assert_response :success
    end
  ensure
    ENV.delete("ADGATE_POSTBACK_IPS")
  end

  test "in production a valid token from an IP that is not allowlisted is still rejected" do
    ENV["ADGATE_POSTBACK_IPS"] = "1.2.3.4"

    with_required_allowlist do
      assert_no_difference "Claim.count" do
        get postbacks_adgate_url, params: postback_params
      end
      assert_response :unauthorized
    end
  ensure
    ENV.delete("ADGATE_POSTBACK_IPS")
  end

  test "silently ignores conversions once the daily limit is reached" do
    AdsController::DAILY_LIMIT.times { |i| @user.claims.create!(server: @server, watched_at: (i + 1).hours.ago) }

    assert_no_difference "Claim.count" do
      get postbacks_adgate_url, params: postback_params
    end
    assert_response :success
  end

  private

  def with_required_allowlist
    Rails.configuration.x.adgate.require_ip_allowlist = true
    yield
  ensure
    Rails.configuration.x.adgate.require_ip_allowlist = false
  end

  def postback_params
    token = Rails.application.message_verifier(:adgate_offer).generate(
      { "user_id" => @user.id, "server_id" => @server.id }, expires_in: 1.hour
    )

    { s1: token, id: "conv-1", payout: "1.50", ip: "9.8.7.6" }
  end
end
