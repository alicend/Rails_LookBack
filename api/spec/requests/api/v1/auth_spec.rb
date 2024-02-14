require "rails_helper"

RSpec.describe "AuthController", type: :request do
  describe "POST /api/v1/signup/request send_sign_up_email" do
    let(:valid_email) { "test@example.com" }
    let(:invalid_email) { "invalid" }
    let(:used_email) { "used@example.com" }

    let!(:user_group) { UserGroup.create!(name: "Example Group") }
    let!(:user) { User.create!(name: "TestUser", email: used_email, password: "password", password_confirmation: "password", user_group:) }

    it "メール送信が成功した場合は200 OKを返す" do
      mail_delivery_double = instance_double("ActionMailer::MessageDelivery", deliver_now: true)
      allow(AuthMailer).to receive(:sign_up_email).with(email: valid_email).and_return(mail_delivery_double)
      post "/api/v1/signup/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:ok)
    end

    it "無効な入力の場合はバッドリクエストを返す" do
      post "/api/v1/signup/request", params: { auth: { email: invalid_email }, email: invalid_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "既に使用されているメールアドレスの場合はバッドリクエストを返す" do
      post "/api/v1/signup/request", params: { auth: { email: used_email }, email: used_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "メール送信に失敗したの場合はサーバーエラーを返す" do
      allow(AuthMailer).to receive(:sign_up_email).with(email: valid_email).and_raise("メール送信エラー")
      post "/api/v1/signup/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "POST /api/v1/invite/request send_invite_email" do
    let(:valid_email) { "test@example.com" }
    let(:invalid_email) { "invalid" }
    let(:used_email) { "used@example.com" }

    let!(:user_group) { UserGroup.create!(name: "Example Group") }
    let!(:user) { User.create!(name: "TestUser", email: used_email, password: "password", password_confirmation: "password", user_group:) }

    it "メール送信が成功した場合は200 OKを返す" do
      cookies[:access_token] = JwtToken.generate_session_token(user.id)
      post "/api/v1/invite/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:ok)
    end

    it "無効な入力の場合はバッドリクエストを返す" do
      post "/api/v1/invite/request", params: { auth: { email: invalid_email }, email: invalid_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "既に使用されているメールアドレスの場合はバッドリクエストを返す" do
      post "/api/v1/invite/request", params: { auth: { email: used_email }, email: used_email }
      expect(response).to have_http_status(:bad_request)
    end

    it "メール送信に失敗したの場合はサーバーエラーを返す" do
      allow(AuthMailer).to receive(:sign_up_email).with(email: valid_email).and_raise("メール送信エラー")
      post "/api/v1/invite/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:internal_server_error)
    end

    it "CookieからユーザIDの取得に失敗した場合はサーバーエラーを返す" do
      post "/api/v1/invite/request", params: { auth: { email: valid_email }, email: valid_email }
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "POST /api/v1/signup create" do
    let(:valid_attributes) {
      {
        username: "TestUser",
        password: "password",
        email: "test@example.com",
        user_group: "Example Group",
      }
    }

    let(:invalid_attributes) {
      {
        username: "",
        password: "",
        email: "",
        user_group: "",
      }
    }

    it "ユーザ作成に成功した場合は200 OKを返す" do
      post "/api/v1/signup", params: { auth: valid_attributes }
      expect(response).to have_http_status(:ok)
    end

    it "ユーザグループ作成に成功" do
      expect {
        post "/api/v1/signup", params: { auth: valid_attributes }
      }.to change { UserGroup.count }.by(1)
    end

    it "ユーザ作成に成功" do
      expect {
        post "/api/v1/signup", params: { auth: valid_attributes }
      }.to change { User.count }.by(1)
    end

    it "無効な入力の場合はバッドリクエストを返す" do
      post "/api/v1/signup", params: { auth: invalid_attributes }
      expect(response).to have_http_status(:bad_request)
    end

    it "無効な入力の場合はユーザグループを作成しない" do
      expect {
        post "/api/v1/signup", params: { auth: invalid_attributes }
      }.to change { UserGroup.count }.by(0)
    end

    it "無効な入力の場合はユーザを作成しない" do
      expect {
        post "/api/v1/signup", params: { auth: invalid_attributes }
      }.to change { User.count }.by(0)
    end
  end

  describe "POST /api/v1/invite/signup invite_create" do
    let!(:user_group) { UserGroup.create!(name: "Example Group") }
    let(:valid_attributes) {
      {
        username: "TestUser",
        password: "password",
        email: "test@example.com",
        user_group: user_group.id,
      }
    }

    let(:invalid_attributes) {
      {
        username: "",
        password: "",
        email: "",
        user_group: "",
      }
    }

    it "ユーザ作成に成功した場合は200 OKを返す" do
      post "/api/v1/invite/signup", params: { auth: valid_attributes }
      expect(response).to have_http_status(:ok)
    end

    it "ユーザ作成に成功" do
      expect {
        post "/api/v1/invite/signup", params: { auth: valid_attributes }
      }.to change { User.count }.by(1)
    end

    it "無効な入力の場合はバッドリクエストを返す" do
      post "/api/v1/invite/signup", params: { auth: invalid_attributes }
      expect(response).to have_http_status(:bad_request)
    end

    it "無効な入力の場合はユーザを作成しない" do
      expect {
        post "/api/v1/invite/signup", params: { auth: invalid_attributes }
      }.to change { User.count }.by(0)
    end
  end

  describe "GET /api/v1/login login" do
    let!(:user_group) { UserGroup.create!(name: "Example Group") }
    let!(:user) { User.create!(name: "TestUser", email: "test@example.com", password: "password", password_confirmation: "password", user_group:) }

    let(:valid_attributes) { { password: "password", email: "test@example.com" } }
    let(:invalid_attributes) { { password: "", email: "" } }
    let(:not_exist_attributes) { { password: "password", email: "not_exist@example.com" } }
    let(:dif_password_attributes) { { password: "dif_password", email: "test@example.com" } }

    it "ログインに成功した場合は200 OKを返す" do
      post "/api/v1/login", params: { auth: valid_attributes }
      expect(response).to have_http_status(:ok)
    end

    it "無効な入力の場合はバッドリクエストを返す" do
      post "/api/v1/login", params: { auth: invalid_attributes }
      expect(response).to have_http_status(:bad_request)
    end

    it "存在しないユーザを入力した場合はバッドリクエストを返す" do
      post "/api/v1/login", params: { auth: not_exist_attributes }
      expect(response).to have_http_status(:bad_request)
    end

    it "間違ったパスワードを入力した場合はバッドリクエストを返す" do
      post "/api/v1/login", params: { auth: dif_password_attributes }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/login/guest guest_login" do
    it "ログインに成功した場合は200 OKを返す" do
      get "/api/v1/login/guest"
      expect(response).to have_http_status(:ok)
    end

    it "ユーザ作成に成功" do
      expect {
        get "/api/v1/login/guest"
      }.to change { User.count }.by(3)
    end
  end

  describe "GET /api/v1/logout logout" do
    it "ログインに成功した場合は200 OKを返す" do
      cookies[:access_token] = JwtToken.generate_session_token(1)
      cookies[:guest_login] = "true"
      get "/api/v1/logout"
      expect(response).to have_http_status(:ok)
    end
  end
end
