# Where a server owner sees what the server has earned and asks to be paid.
class ServerPayoutsController < ApplicationController
  before_action :require_login
  before_action :check_banned!
  before_action :set_server

  def index
    @contract = @server.payout_contract
    @blocker = @server.approved? ? @server.payout_blocker(contract: @contract) : :not_approved
    @payouts = @server.payouts.order(created_at: :desc)
    @last_payout = @server.last_payout
  end

  def create
    payout = Payout.issue!(@server, requested_by: current_user)
    redirect_to server_payouts_path(@server),
                notice: t("server_payouts.requested", amount: Payout.format_cents(payout.amount_cents, payout.currency))
  rescue Payout::NotEligible => e
    redirect_to server_payouts_path(@server), alert: t("server_payouts.blockers.#{e.reason}", minimum: minimum)
  end

  private

  def minimum
    Payout.format_cents(PayoutPolicy.minimum_cents, PayoutPolicy.currency)
  end

  def set_server
    @server = current_user.servers.approved.find_by(id: params[:server_id])
    redirect_to servers_path, alert: t("server_payouts.blockers.not_approved") unless @server
  end
end
