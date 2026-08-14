class Admin::FraudFlagsController < Admin::BaseController
  before_action :set_fraud_flag, only: [ :show, :update ]

  def index
    @fraud_flags = FraudFlag.includes(:user, claim: :server).order(created_at: :desc)
    @fraud_flags = @fraud_flags.where(status: params[:status]) if params[:status].present?
  end

  def show; end

  def update
    if @fraud_flag.update(fraud_flag_params)
      redirect_to admin_fraud_flag_path(@fraud_flag), notice: "Fraud flag updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_fraud_flag
    @fraud_flag = FraudFlag.find(params[:id])
  end

  def fraud_flag_params
    params.require(:fraud_flag).permit(:status)
  end
end
