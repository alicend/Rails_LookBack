class InviteMailer < ApplicationMailer
  default from: "Look Back Calendar <no-reply@#{Settings.email_domain}>"

  def invite_email(email:, user_group_id:)
    email_token = JwtToken.generate_email_token(email)
    user_group_id_token = JwtToken.generate_user_group_id_token(user_group_id)
    @url = "#{Settings.front_domain}/sign-up?&email=#{email_token}&user-group-id=#{user_group_id_token}"
    mail(to: email, subject: "【Look Back Calendar】登録のお願い")
  end
end
