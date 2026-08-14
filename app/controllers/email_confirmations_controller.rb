class EmailConfirmationsController < ApplicationController
  def show
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user
      user.confirm!
      redirect_to(logged_in? ? dashboard_path : root_path, notice: "Email confirmed — thanks!")
    else
      redirect_to root_path, alert: "That confirmation link is invalid or expired."
    end
  end

  def create
    return redirect_to root_path unless logged_in?

    if current_user.confirmed?
      redirect_to dashboard_path, notice: "Your email is already confirmed."
    else
      current_user.send_confirmation_email
      redirect_to dashboard_path, notice: "Confirmation email sent."
    end
  end
end
