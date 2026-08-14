class Admin::ServersController < Admin::BaseController
  def index
    @status = params[:status]
    @servers = Server.order(created_at: :desc)
    @servers = @servers.where(status: @status) if @status.present?
  end

  def show
    @server = Server.find(params[:id])
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