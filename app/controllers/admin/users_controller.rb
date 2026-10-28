# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :require_user_management!
  before_action :set_user, only: [ :show, :edit, :update, :ban, :unban ]

  def index
    @users = User.order(:created_at)
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  def show; end
  # Roles are edited on the user's detail page; there is no separate edit view.
  def edit
    redirect_to admin_user_path(@user)
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Uživatel byl upraven"
    else
      redirect_to admin_user_path(@user), alert: "Roli se nepodařilo změnit."
    end
  end

  def ban
    duration_days = params[:duration].presence&.to_i
    @user.update!(banned_at: Time.current, banned_until: duration_days ? duration_days.days.from_now : nil)
    suffix = duration_days ? " na #{duration_days} dní" : " natrvalo"
    redirect_to admin_users_path, notice: "#{@user.minecraft_nick} byl zabanován#{suffix}"
  end

  def unban
    @user.update!(banned_at: nil, banned_until: nil)
    redirect_to admin_users_path, notice: "#{@user.minecraft_nick} byl odbanován"
  end

  private

  def require_user_management!
    redirect_to admin_root_path, alert: "Nemáš oprávnění" unless current_user&.can_manage_users?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    allowed_roles = current_user.superadmin? ? User::ROLES : User::ROLES - [ "superadmin" ]
    role = params.dig(:user, :role)
    { role: (role if allowed_roles.include?(role)) }
  end
end
