module PluginAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_server!
  end

  private

  def authenticate_server!
    api_key = request.headers["X-Api-Key"].to_s
    api_secret = request.headers["X-Api-Secret"].to_s
    candidate = Server.approved.find_by(api_key: api_key) if api_key.present?

    if candidate && secrets_match?(candidate.api_secret, api_secret)
      @current_server = candidate
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  def secrets_match?(expected, given)
    expected.bytesize == given.bytesize && ActiveSupport::SecurityUtils.secure_compare(expected, given)
  end
end
