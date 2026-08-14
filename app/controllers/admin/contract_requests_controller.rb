class Admin::ContractRequestsController < Admin::BaseController
  before_action :set_contract_request, only: [:show, :update]

  def index
    @contract_requests = ContractRequest.includes(:server, :user).order(created_at: :desc)
    @contract_requests = @contract_requests.where(status: params[:status]) if params[:status].present?
  end

  def show; end

  def update
    if @contract_request.update(contract_request_params)
      redirect_to admin_contract_request_path(@contract_request), notice: "Žádost byla aktualizována"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_contract_request
    @contract_request = ContractRequest.find(params[:id])
  end

  def contract_request_params
    params.require(:contract_request).permit(:status)
  end
end