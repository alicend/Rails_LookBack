require "rails_helper"

RSpec.describe AuthMailer, type: :mailer do
  describe "sign_up_email" do
    let(:user_email) { "user@example.com" }
    let(:mail) { AuthMailer.sign_up_email(email: user_email) }

    before do
      allow(JwtToken).to receive(:generate_email_token).with(user_email).and_return("email_token")
    end

    it "メールが正しい受信者に送信されること" do
      expect(mail.to).to eq([user_email])
    end

    it "正しい件名で送信されること" do
      expect(mail.subject).to eq("【Look Back Calendar】登録のお願い")
    end

    it "送信元が正しいこと" do
      expect(mail.from).to eq(["no-reply@lookback-calendar.com"])
    end

    it "メール本文にサインアップURLが含まれていること" do
      expected_url = "#{Settings.front_domain}/sign-up?&email=email_token"
      expected_url = CGI.escapeHTML(expected_url)
      expect(mail.body.encoded).to include(expected_url)
    end
  end
end
