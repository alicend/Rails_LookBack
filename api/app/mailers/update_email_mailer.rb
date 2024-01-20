class UpdateEmailMailer < ApplicationMailer
  default from: "Look Back Calendar <no-reply@lookback-calendar.com>"

  def update_email_email(email:)
    email_token = JwtToken.generate_email_token(email)
    @url = "#{Settings.front_domain}/update/email?&email=#{email_token}"
    mail(to: email, subject: "【Look Back Calendar】メールアドレス更新のお願い")
  end
end
