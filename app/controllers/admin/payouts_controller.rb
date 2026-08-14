class Admin::PayoutsController < Admin::BaseController
  before_action :require_superadmin!
  before_action :set_payout, only: [ :show, :mark_paid ]

  def index
    @servers = Server.approved.order(:name)
    @payouts = Payout.includes(:server).order(created_at: :desc)
  end

  def show; end

  def create
    server = Server.approved.find(params[:server_id])
    balance = server.balance_cents

    if balance <= 0
      redirect_to admin_payouts_path, alert: "#{server.name} has no balance to pay out." and return
    end

    server.payouts.create!(amount_cents: balance, currency: "USD")
    redirect_to admin_payouts_path, notice: "Payout of #{Payout.format_cents(balance)} created for #{server.name}."
  end

  def mark_paid
    @payout.update!(status: "paid", paid_at: Time.current)
    redirect_to admin_payout_path(@payout), notice: "Payout marked as paid."
  end

  private

  def require_superadmin!
    redirect_to admin_root_path, alert: "Nemáš oprávnění k této sekci." unless current_user.superadmin?
  end

  def set_payout
    @payout = Payout.find(params[:id])
  end
end
