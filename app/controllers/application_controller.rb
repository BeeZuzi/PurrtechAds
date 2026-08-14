class ApplicationController < ActionController::Base
  around_action :switch_locale
  helper_method :current_user, :logged_in?

  private

  def switch_locale(&action)
    locale = session[:locale].presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to root_path, alert: "You need to sign in first"
    end
  end

  # Regenerates the session (session-fixation protection on login/signup/password
  # reset) while keeping the visitor's language choice, which would otherwise be
  # wiped along with everything else in the session hash.
  def reset_session_preserving_locale
    locale = session[:locale]
    reset_session
    session[:locale] = locale
  end

   def check_banned!
    if current_user&.banned?
      reset_session
      redirect_to new_session_path, alert: "Tvůj účet byl zablokován."
    end
  end
  
end
