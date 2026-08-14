class AdsController < ApplicationController
  before_action :require_login

  COOLDOWN = 2.minutes
  DAILY_LIMIT = 20

  def watch
    @servers = Server.approved.order(:name)
    @server = @servers.find_by(id: params[:server_id])
  end

  def claim
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

  def cooling_down?
    current_user.claims.where("watched_at > ?", COOLDOWN.ago).exists?
  end

  def daily_limit_reached?
    current_user.claims.where("watched_at > ?", 1.day.ago).count >= DAILY_LIMIT
  end
end
