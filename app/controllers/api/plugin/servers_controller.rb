module Api
  module Plugin
    class ServersController < Api::BaseController
      include PluginAuthenticatable

      def show
        return render_not_found unless requested_server_matches?

        render json: server_payload
      end

      def plugin_config
        return render_not_found unless requested_server_matches?

        render json: server_payload
      end

      private

      def requested_server_matches?
        params[:id].to_s == @current_server.id.to_s
      end

      def render_not_found
        render json: { error: "not_found" }, status: :not_found
      end

      def server_payload
        { id: @current_server.id, name: @current_server.name, status: @current_server.status }
      end
    end
  end
end
