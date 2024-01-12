class PasswordResetMailer < ApplicationMailer
  default from: "Look Back Calendar <no-reply@lookback-calendar.com>"

  def password_reset_email(email:)
    email_token = JwtToken.generate_email_token(email)
    @url = "#{Settings.front_domain}/update/password?&email=#{email_token}"
    mail(to: email, subject: "【Look Back Calendar】パスワード更新のお願い")
  end
end
