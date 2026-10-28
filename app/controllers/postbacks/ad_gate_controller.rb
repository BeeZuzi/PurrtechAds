module Postbacks
  # Server-to-server callback AdGate calls when a player completes an offer.
  # This is the ONLY place an AdGate-sourced Claim gets created — see
  # AdsController#offers for the outbound side that sends the player there.
  #
  # Two layers of trust that must both hold in production: (1) the IP
  # allowlist (ADGATE_POSTBACK_IPS — the real AdGate/Prodege IPs from your
  # dashboard; postback docs list ~9), and (2) the `s1` token, signed with our
  # own secret_key_base, which ties the conversion to a user and a server.
  # The token alone is not enough: the player sees it in the wall URL and could
  # call this endpoint themselves.
  class AdGateController < Api::BaseController
    def create
      return render_unauthorized unless ip_allowed?

      payload = verified_payload
      return render_unauthorized if payload.nil?

      conversion_id = params[:id].presence
      if conversion_id.present? && (existing = Claim.find_by(external_id: conversion_id))
        return render json: { status: "ok", claim_id: existing.id }
      end

      user = User.find_by(id: payload[:user_id])
      server = Server.approved.find_by(id: payload[:server_id])
      return render_unauthorized if user.nil? || server.nil?

      if user.claims.where("watched_at > ?", 1.day.ago).count >= AdsController::DAILY_LIMIT
        return render json: { status: "ignored", reason: "daily_limit" }
      end

      claim = user.claims.create!(
        server: server,
        ip_address: params[:ip].presence || request.remote_ip,
        external_id: conversion_id,
        revenue_cents: revenue_cents_from(params[:payout]),
        source: "adgate"
      )
      FraudDetector.new(claim).call

      render json: { status: "ok", claim_id: claim.id }
    end

    private

    # With a list, only those IPs get in. Without one the request is let through
    # only where config.x.adgate.require_ip_allowlist is off (development and
    # test) — in production an empty list rejects everything, because the `s1`
    # token appears in the player's own wall URL and so proves nothing alone.
    def ip_allowed?
      return allowed_ips.include?(request.remote_ip) if allowed_ips.present?

      !Rails.configuration.x.adgate.require_ip_allowlist
    end

    def allowed_ips
      Rails.application.credentials.dig(:adgate, :postback_ips) ||
        ENV["ADGATE_POSTBACK_IPS"]&.split(",")&.map(&:strip) || []
    end

    def verified_payload
      token = params[:s1]
      return nil if token.blank?

      Rails.application.message_verifier(:adgate_offer).verify(token).symbolize_keys
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    def revenue_cents_from(payout)
      return nil if payout.blank?

      (payout.to_f * 100).round
    end

    def render_unauthorized
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
