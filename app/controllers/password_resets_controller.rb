class PasswordResetsController < ApplicationController
  rate_limit to: 5, within: 15.minutes, only: :create,
             with: -> { redirect_to root_path, alert: "Too many reset attempts. Please wait a bit and try again." }

  def new; end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)
    user&.send_password_reset_email

    redirect_to root_path, notice: "If that email exists, we've sent a password reset link."
  end

  def edit
    @token = params[:token]
    redirect_to new_password_reset_path, alert: "That link is invalid or expired." unless find_user
  end

  def update
    user = find_user

    if user.nil?
      redirect_to new_password_reset_path, alert: "That link is invalid or expired." and return
    end

    if user.update(password_params)
      reset_session_preserving_locale
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Password updated — you're signed in."
    else
      @token = params[:token]
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user
    User.find_by_token_for(:password_reset, params[:token])
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
