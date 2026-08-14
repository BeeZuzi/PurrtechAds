class UsersController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create,
             with: -> { redirect_to root_path, alert: "Too many accounts created from here. Please try again later." }

  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session_preserving_locale
      session[:user_id] = @user.id
      @user.send_confirmation_email
      redirect_to dashboard_path, notice: "Account created — welcome! Check your email to confirm your account."
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :minecraft_nick, :password, :password_confirmation)
  end
end
