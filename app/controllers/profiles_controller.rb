class ProfilesController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @recent_claims = @user.claims.includes(:server).order(watched_at: :desc).limit(5)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, :minecraft_nick, :minecraft_uuid, :password, :password_confirmation)
  end
end
