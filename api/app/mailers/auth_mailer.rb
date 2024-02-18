class AuthMailer < ApplicationMailer
  default from: "Look Back Calendar <no-reply@#{Settings.email_domain}>"

  def sign_up_email(email:)
    email_token = JwtToken.generate_email_token(email)
    @url = "#{Settings.front_domain}/sign-up?&email=#{email_token}"
    mail(to: email, subject: "【Look Back Calendar】登録のお願い")
  end
end
