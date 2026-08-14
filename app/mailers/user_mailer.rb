class UserMailer < ApplicationMailer
  def confirmation_email(user)
    @user = user
    @token = user.generate_token_for(:email_confirmation)
    mail(to: @user.email, subject: "Confirm your Ads account")
  end

  def password_reset(user)
    @user = user
    @token = user.generate_token_for(:password_reset)
    mail(to: @user.email, subject: "Reset your Ads password")
  end
end
