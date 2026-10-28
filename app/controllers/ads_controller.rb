class AdsController < ApplicationController
  before_action :require_login

  COOLDOWN = 2.minutes
  DAILY_LIMIT = 20

  helper_method :adgate_configured?, :simulated_claims_allowed?

  def watch
    @servers = Server.approved.order(:name)
    @server = @servers.find_by(id: params[:server_id])
  end

  # Sends the player to AdGate's offer wall. The claim itself is NOT created
  # here — with a real ad network we don't control whether/when the player
  # finishes an offer, so the claim only comes into existence once AdGate
  # confirms a conversion via Postbacks::AdGateController#create.
  def offers
    server = Server.approved.find_by(id: params[:server_id])
    return redirect_to(watch_ad_path, alert: "Please confirm your email before claiming rewards.") unless current_user.confirmed?
    return redirect_to(watch_ad_path, alert: "Pick a valid server first.") if server.nil?
    return redirect_to(watch_ad_path, alert: "You've hit today's ad limit — try again tomorrow.") if daily_limit_reached?
    return redirect_to(watch_ad_path, alert: "Offers aren't available yet.") unless adgate_configured?

    token = Rails.application.message_verifier(:adgate_offer)
                 .generate({ user_id: current_user.id, server_id: server.id }, expires_in: 1.hour)

    redirect_to "https://wall.adgaterewards.com/#{adgate_wall_id}/#{token}", allow_other_host: true
  end

  # Local-development stand-in for AdGate: creates the claim right after the
  # simulated countdown. Disabled in production.
  def claim
    return redirect_to(watch_ad_path, alert: "Offers aren't available yet.") unless simulated_claims_allowed?

    server = Server.approved.find_by(id: params[:server_id])
    return redirect_to(watch_ad_path, alert: "Please confirm your email before claiming rewards.") unless current_user.confirmed?
    return redirect_to(watch_ad_path, alert: "Pick a valid server first.") if server.nil?
    return redirect_to(watch_ad_path, alert: "Please wait a bit before watching another ad.") if cooling_down?
    return redirect_to(watch_ad_path, alert: "You've hit today's ad limit — try again tomorrow.") if daily_limit_reached?

    @claim = current_user.claims.create!(server: server, ip_address: request.remote_ip)
    FraudDetector.new(@claim).call

    redirect_to watch_ad_path, notice: "Reward claimed — #{server.name}'s plugin will pick it up shortly."
  end

  private

  # The plugin pays out any claim it finds, so a claim made without an ad would
  # hand out free rewards. Only allowed where config.x.ads.simulated_claims is on.
  def simulated_claims_allowed?
    Rails.configuration.x.ads.simulated_claims
  end

  def adgate_configured?
    adgate_wall_id.present?
  end

  def adgate_wall_id
    Rails.application.credentials.dig(:adgate, :wall_id) || ENV["ADGATE_WALL_ID"]
  end

  def cooling_down?
    current_user.claims.where("watched_at > ?", COOLDOWN.ago).exists?
  end

  def daily_limit_reached?
    current_user.claims.where("watched_at > ?", 1.day.ago).count >= DAILY_LIMIT
  end
end
