require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "password_reset_email" do
    let(:email) { "user@example.com" }
    let(:mail) { PasswordResetMailer.password_reset_email(email:) }

    before do
      allow(JwtToken).to receive(:generate_email_token).with(email).and_return("email_token")
    end

    it "メールが正しい受信者に送信されること" do
      expect(mail.to).to eq([email])
    end

    it "正しい件名で送信されること" do
      expect(mail.subject).to eq("【Look Back Calendar】パスワード更新のお願い")
    end

    it "送信元が正しいこと" do
      expect(mail.from).to eq(["no-reply@#{Settings.email_domain}"])
    end

    it "メール本文にパスワード更新URLが含まれていること" do
      expected_url = "#{Settings.front_domain}/update/password?&email=email_token"
      expected_url = CGI.escapeHTML(expected_url)
      expect(mail.body.encoded).to include(expected_url)
    end
  end
end
