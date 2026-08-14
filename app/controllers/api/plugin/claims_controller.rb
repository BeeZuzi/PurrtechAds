module Api
  module Plugin
    class ClaimsController < Api::BaseController
      include PluginAuthenticatable

      before_action :set_claim, only: [ :redeem, :fail ]

      def index
        player = User.find_by(minecraft_uuid: params[:uuid]) if params[:uuid].present?
        claims = player ? @current_server.claims.claimable.where(user: player) : Claim.none
        render json: claims.map { |claim| claim_payload(claim) }
      end

      def redeem
        if @claim.claimable?
          @claim.update!(status: "redeemed", redeemed_at: Time.current)
          render json: claim_payload(@claim)
        else
          render json: { error: "not_claimable", status: @claim.status }, status: :unprocessable_entity
        end
      end

      def fail
        if @claim.pending?
          @claim.update!(status: "failed", failed_at: Time.current)
          render json: claim_payload(@claim)
        else
          render json: { error: "not_pending", status: @claim.status }, status: :unprocessable_entity
        end
      end

      private

      def set_claim
        @claim = @current_server.claims.find_by(id: params[:id])
        render json: { error: "not_found" }, status: :not_found unless @claim
      end

      def claim_payload(claim)
        {
          id: claim.id,
          token: claim.token,
          status: claim.status,
          minecraft_nick: claim.user.minecraft_nick,
          watched_at: claim.watched_at,
          expires_at: claim.expires_at
        }
      end
    end
  end
end
