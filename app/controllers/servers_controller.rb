class ServersController < ApplicationController
  before_action :require_login

  def index
    @servers = current_user.servers
  end

  def new
    @server = current_user.servers.new
  end

  def create
    @server = current_user.servers.new(server_params)
    if @server.save
      redirect_to servers_path, notice: "Server registered — follow the setup steps below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def request_contract
    # Zatím placeholder — později napojíš na reálný proces (email, ticket, admin review)
    redirect_to servers_path, notice: "Contract request sent — we'll get back to you soon."
  end

  private

  def server_params
    params.require(:server).permit(:name, :description)
  end
end
