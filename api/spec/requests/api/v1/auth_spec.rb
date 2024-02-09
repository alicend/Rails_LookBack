require "rails_helper"

RSpec.describe "SignUp", type: :request do
  describe "POST /api/v1/signup/request" do
    let(:valid_email) { "test@example.com" }
    let(:invalid_email) { "invalid" }
    let(:used_email) { "used@example.com" }

    let!(:user_group) { UserGroup.create!(name: "Example Group") }
    let!(:user) { User.create!(name: "John Doe", email: used_email, password: "password", password_confirmation: "password", user_group:) }

    it "メール送信が成功した場合、200 OKを返す" do
      mail_delivery_double = instance_double("ActionMailer::MessageDelivery", deliver_now: true)
      allow(AuthMailer).to receive(:sign_up_email).with(email: valid_email).and_return(mail_delivery_double)
      post "/api/v1/signup/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:ok)
    end

    it "無効なユーザー入力でバッドリクエストを返す" do
      post "/api/v1/signup/request", params: { auth: { email: invalid_email }, email: invalid_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "既に使用されているメールアドレスでバッドリクエストを返す" do
      post "/api/v1/signup/request", params: { auth: { email: used_email }, email: used_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "メール送信に失敗した場合、サーバーエラーを返す" do
      allow(AuthMailer).to receive(:sign_up_email).with(email: valid_email).and_raise("メール送信エラー")
      post "/api/v1/signup/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
