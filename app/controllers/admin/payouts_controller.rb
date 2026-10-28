class Admin::PayoutsController < Admin::BaseController
  before_action :require_superadmin!
  before_action :set_payout, only: [ :show, :mark_paid, :mark_failed ]

  BLOCKER_MESSAGES = {
    no_contract: "no approved contract yet.",
    no_terms: "the approved contract has no accepted partner terms. Ask the owner to submit a new request.",
    below_minimum: "the balance is below the minimum payout.",
    claims_changed: "earnings changed while the payout was created, try again."
  }.freeze

  def index
    @servers = Server.approved.order(:name)
    @payouts = Payout.includes(:server, :requested_by).order(created_at: :desc)
  end

  def show; end

  def create
    server = Server.approved.find(params[:server_id])
    payout = Payout.issue!(server)
    redirect_to admin_payout_path(payout),
                notice: "Payout of #{Payout.format_cents(payout.amount_cents, payout.currency)} created for #{server.name}."
  rescue Payout::NotEligible => e
    redirect_to admin_payouts_path, alert: "#{server.name}: #{BLOCKER_MESSAGES.fetch(e.reason)}"
  end

  def mark_paid
    if @payout.mark_paid!
      redirect_to admin_payout_path(@payout), notice: "Payout marked as paid."
    else
      redirect_to admin_payout_path(@payout), alert: "Only a pending payout can be marked as paid."
    end
  end

  def mark_failed
    if @payout.mark_failed!
      redirect_to admin_payout_path(@payout), notice: "Payout marked as failed. Its earnings went back to the server's balance."
    else
      redirect_to admin_payout_path(@payout), alert: "Only a pending payout can be marked as failed."
    end
  end

  private

  def require_superadmin!
    redirect_to admin_root_path, alert: "Nemáš oprávnění k této sekci." unless current_user.superadmin?
  end

  def set_payout
    @payout = Payout.find(params[:id])
  end
end
