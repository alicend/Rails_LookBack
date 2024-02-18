require "rails_helper"

RSpec.describe UpdateEmailMailer, type: :mailer do
  describe "update_email_email" do
    let(:email) { "user@example.com" }
    let(:mail) { UpdateEmailMailer.update_email_email(email:) }

    before do
      allow(JwtToken).to receive(:generate_email_token).with(email).and_return("email_token")
    end

    it "メールが正しい受信者に送信されること" do
      expect(mail.to).to eq([email])
    end

    it "正しい件名で送信されること" do
      expect(mail.subject).to eq("【Look Back Calendar】メールアドレス更新のお願い")
    end

    it "送信元が正しいこと" do
      expect(mail.from).to eq(["no-reply@lookback-calendar.com"])
    end

    it "メール本文にメールアドレス更新URLが含まれていること" do
      expected_url = "#{Settings.front_domain}/update/email?&email=email_token"
      expected_url = CGI.escapeHTML(expected_url)
      expect(mail.body.encoded).to include(expected_url)
    end
  end
end
