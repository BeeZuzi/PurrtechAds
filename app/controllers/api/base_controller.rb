module Api
  # Machine-to-machine API for the Minecraft plugin — no sessions/cookies/CSRF,
  # authenticated per-request via Server api_key/api_secret headers instead.
  class BaseController < ActionController::API
  end
end
