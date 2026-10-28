class Admin::ServersController < Admin::BaseController
  def index
    @status = params[:status]
    @servers = Server.order(created_at: :desc)
    @servers = @servers.where(status: @status) if @status.present?
    @servers = @servers.includes(:user).to_a
  end

  def show
    @server = Server.find(params[:id])
    @payouts = @server.payouts.includes(:requested_by).order(created_at: :desc).to_a
    @claims_per_payout = Claim.where(payout_id: @payouts.map(&:id)).group(:payout_id).count
  end

  def update
    @server = Server.find(params[:id])
    if @server.update(status: params[:status])
      redirect_to admin_server_path(@server), notice: "Status byl aktualizován."
    else
      redirect_to admin_server_path(@server), alert: "Nepodařilo se uložit změny."
    end
  end
end
