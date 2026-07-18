class ContractRequestsController < ApplicationController
  def new
    @server = Server.find(params[:server_id])
    @contract_request = @server.build_contract_request
  end

  def create
    @server = Server.find(params[:server_id])
    @contract_request = @server.build_contract_request(contract_request_params)

    if @contract_request.save
      redirect_to server_path(@server), notice: "Your contract request has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contract_request_params
    params.require(:contract_request).permit(:message)
  end
end
