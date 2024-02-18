require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do
  describe "invite_email" do
    let(:email) { "user@example.com" }
    let(:user_group_id) { "123" }
    let(:mail) { InviteMailer.invite_email(email:, user_group_id:) }

    before do
      allow(JwtToken).to receive(:generate_email_token).with(email).and_return("email_token")
      allow(JwtToken).to receive(:generate_user_group_id_token).with(user_group_id).and_return("user_group_id_token")
    end

    it "メールが正しい受信者に送信されること" do
      expect(mail.to).to eq([email])
    end

    it "正しい件名で送信されること" do
      expect(mail.subject).to eq("【Look Back Calendar】登録のお願い")
    end

    it "送信元が正しいこと" do
      expect(mail.from).to eq(["no-reply@#{Settings.email_domain}"])
    end

    it "メール本文に招待URLが含まれていること" do
      expected_url = "#{Settings.front_domain}/sign-up?&email=email_token&user-group-id=user_group_id_token"
      expected_url = CGI.escapeHTML(expected_url)
      expect(mail.body.encoded).to include(expected_url)
    end
  end
end
