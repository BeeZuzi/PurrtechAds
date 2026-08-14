class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :require_admin!

  private

  def require_admin!
    unless current_user&.can_access_admin?
      redirect_to root_path, alert: "Nemáš oprávnění k této sekci."
    end
  end
end
