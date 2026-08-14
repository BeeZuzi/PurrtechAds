class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to root_path, alert: "Too many login attempts. Please wait a few minutes and try again." }

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.banned?
      redirect_to banned_path(user_id: user.id)
      return
    end

    if user&.authenticate(params[:password])
      reset_session_preserving_locale
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Přihlášení proběhlo úspěšně."
    else
      flash.now[:alert] = "Nesprávný email nebo heslo."
      render "home/index", status: :unprocessable_entity
    end
  end

  def banned
    @user = User.find_by(id: params[:user_id])
    redirect_to root_path and return unless @user&.banned?
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out"
  end
end
