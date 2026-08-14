class ContractRequestsController < ApplicationController
  before_action :require_login
  before_action :set_server

  def new
    @contract_request = @server.contract_requests.build
  end

  def create
    @contract_request = @server.contract_requests.build(contract_request_params)
    @contract_request.user = current_user

    if @contract_request.save
      redirect_to server_path(@server), notice: "Your contract request has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_server
    @server = Server.find(params[:server_id])
  end

  def contract_request_params
    params.require(:contract_request).permit(
      :entity_type, :legal_name, :country_code, :tax_id,
      :registered_address, :contact_email, :phone,
      :message, :preferred_currency, :payout_method
    )
  end
end