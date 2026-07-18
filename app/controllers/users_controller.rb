class UsersController < ApplicationController
  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

 def create
  @user = User.new(user_params)
  if @user.save
    session[:user_id] = @user.id
    redirect_to dashboard_path, notice: "Account created — welcome!"
  else
    render "home/index", status: :unprocessable_entity
  end
end

  private

  def user_params
    params.require(:user).permit(:email, :minecraft_nick, :password, :password_confirmation)
  end
end