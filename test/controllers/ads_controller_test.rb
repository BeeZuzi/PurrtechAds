require "test_helper"

class AdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:player)
    @server = servers(:approved_server)
  end

  test "redirects to root when not logged in" do
    get watch_ad_url
    assert_redirected_to root_url
  end

  test "lists only approved servers" do
    sign_in_as(@user)
    get watch_ad_url
    assert_response :success
    assert_select "option", text: @server.name
    assert_select "option", text: servers(:pending_server).name, count: 0
  end

  test "claim is blocked until the email is confirmed" do
    @user.update!(confirmed_at: nil)
    sign_in_as(@user)

    assert_no_difference "Claim.count" do
      post watch_ad_url, params: { server_id: @server.id }
    end
    assert_redirected_to watch_ad_url
  end

  test "claim succeeds for a confirmed user on an approved server" do
    sign_in_as(@user)

    assert_difference "Claim.count", 1 do
      post watch_ad_url, params: { server_id: @server.id }
    end

    claim = Claim.last
    assert_equal @user, claim.user
    assert_equal @server, claim.server
    assert claim.pending?
  end

  test "claim is blocked by the cooldown" do
    sign_in_as(@user)
    @user.claims.create!(server: @server, watched_at: 30.seconds.ago)

    assert_no_difference "Claim.count" do
      post watch_ad_url, params: { server_id: @server.id }
    end
  end

  test "claim is blocked once the daily limit is reached" do
    sign_in_as(@user)
    AdsController::DAILY_LIMIT.times { |i| @user.claims.create!(server: @server, watched_at: (i + 1).hours.ago) }

    assert_no_difference "Claim.count" do
      post watch_ad_url, params: { server_id: @server.id }
    end
  end

  test "claim rejects a non-approved server" do
    sign_in_as(@user)

    assert_no_difference "Claim.count" do
      post watch_ad_url, params: { server_id: servers(:pending_server).id }
    end
  end

  test "offers redirects to root without creating a claim when AdGate isn't configured" do
    sign_in_as(@user)

    assert_no_difference "Claim.count" do
      get ad_offers_url(server_id: @server.id)
    end
    assert_redirected_to watch_ad_url
  end

  test "offers redirects to the AdGate wall with a signed token when configured" do
    sign_in_as(@user)

    with_adgate_wall_id("test-wall") do
      get ad_offers_url(server_id: @server.id)
    end

    assert_response :redirect
    redirect_uri = URI.parse(response.location)
    assert_equal "wall.adgaterewards.com", redirect_uri.host
    assert_match %r{\A/test-wall/}, redirect_uri.path

    token = redirect_uri.path.split("/").last
    payload = Rails.application.message_verifier(:adgate_offer).verify(token)
    assert_equal @user.id, payload["user_id"]
    assert_equal @server.id, payload["server_id"]
  end

  test "offers is blocked once the daily limit is reached, even when AdGate is configured" do
    sign_in_as(@user)
    AdsController::DAILY_LIMIT.times { |i| @user.claims.create!(server: @server, watched_at: (i + 1).hours.ago) }

    with_adgate_wall_id("test-wall") do
      get ad_offers_url(server_id: @server.id)
    end

    assert_redirected_to watch_ad_url
  end

  test "claim creates nothing when simulated claims are off, as in production" do
    @user.update!(confirmed_at: Time.current)
    sign_in_as(@user)

    without_simulated_claims do
      assert_no_difference "Claim.count" do
        post claim_ad_url, params: { server_id: @server.id }
      end
    end
    assert_redirected_to watch_ad_url
  end

  test "the watch page offers no countdown without AdGate when simulated claims are off" do
    sign_in_as(@user)

    without_simulated_claims do
      get watch_ad_url(server_id: @server.id)
    end

    assert_response :success
    assert_select "[data-controller='ad-watch']", count: 0
    assert_select "form[action='#{claim_ad_path}']", count: 0
  end

  private

  def without_simulated_claims
    Rails.configuration.x.ads.simulated_claims = false
    yield
  ensure
    Rails.configuration.x.ads.simulated_claims = true
  end

  def with_adgate_wall_id(wall_id)
    ENV["ADGATE_WALL_ID"] = wall_id
    yield
  ensure
    ENV.delete("ADGATE_WALL_ID")
  end
end
