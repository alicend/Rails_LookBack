require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:user_group) { UserGroup.create!(name: "Example Group") }
  let!(:user) { User.create!(name: "TestUser", email: "test@example.com", password: "password", password_confirmation: "password", user_group:) }

  describe "GET /api/v1/users index" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "ユーザの取得に成功した場合はステータスコード:200 OKを返す" do
        get "/api/v1/users"
        expect(response).to have_http_status(:ok)
      end

      it "ユーザの取得に成功した場合はレスポンスにユーザが含まれる" do
        get "/api/v1/users"
        expect(JSON.parse(response.body)).to have_key("users")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        get "/api/v1/users"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        get "/api/v1/users"
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "GET /api/v1/users/me index" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "ユーザの取得に成功した場合はステータスコード:200 OKを返す" do
        get "/api/v1/users/me"
        expect(response).to have_http_status(:ok)
      end

      it "ユーザの取得に成功した場合はレスポンスにユーザが含まれる" do
        get "/api/v1/users/me"
        expect(JSON.parse(response.body)).to have_key("user")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        get "/api/v1/users/me"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        get "/api/v1/users/me"
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "POST /api/v1/users/me/email/request send_update_email_email" do
    let(:valid_attributes) { { email: "updated@example.com" } }
    let(:invalid_attributes) { { email: "" } }
    let(:unused_email_attributes) { { email: "unused@example.com" } }
    let!(:unused_user) { User.create!(name: "UnusedUser", email: "unused@example.com", password: "password", password_confirmation: "password", user_group:) }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "メール送信が成功した場合はステータスコード:200 OKを返す" do
        mail_delivery_double = instance_double("ActionMailer::MessageDelivery", deliver_now: true)
        allow(UpdateEmailMailer).to receive(:update_email_email).with(valid_attributes).and_return(mail_delivery_double)
        post "/api/v1/users/me/email/request", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        post "/api/v1/users/me/email/request", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はエラーを返す" do
        post "/api/v1/users/me/email/request", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "未使用のメールアドレスの場合はステータスコード:400 バッドリクエストを返す" do
        post "/api/v1/users/me/email/request", params: unused_email_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "未使用のメールアドレスの場合はエラーを返す" do
        post "/api/v1/users/me/email/request", params: unused_email_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "メール送信に失敗したの場合はステータスコード:500 サーバーエラーを返す" do
        allow(UpdateEmailMailer).to receive(:update_email_email).with(valid_attributes).and_raise("メール送信エラー")
        post "/api/v1/users/me/email/request", params: valid_attributes
        expect(response).to have_http_status(:internal_server_error)
      end

      it "メール送信に失敗したの場合はエラーを返す" do
        allow(UpdateEmailMailer).to receive(:update_email_email).with(valid_attributes).and_raise("メール送信エラー")
        post "/api/v1/users/me/email/request", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        post "/api/v1/users/me/email/request", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        post "/api/v1/users/me/email/request", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "POST /api/v1/users/password/request send_email_reset_password" do
    let(:valid_attributes) { { email: "test@example.com" } }
    let(:invalid_attributes) { { email: "" } }
    let(:used_email_attributes) { { email: "used@example.com" } }

    it "メール送信が成功した場合はステータスコード:200 OKを返す" do
      mail_delivery_double = instance_double("ActionMailer::MessageDelivery", deliver_now: true)
      allow(PasswordResetMailer).to receive(:password_reset_email).with(valid_attributes).and_return(mail_delivery_double)
      post "/api/v1/users/password/request", params: valid_attributes
      expect(response).to have_http_status(:ok)
    end

    it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
      post "/api/v1/users/password/request", params: invalid_attributes
      expect(response).to have_http_status(:bad_request)
    end

    it "無効な入力の場合はエラーを返す" do
      post "/api/v1/users/password/request", params: invalid_attributes
      expect(JSON.parse(response.body)).to have_key("error")
    end

    it "既に使用されているメールアドレスの場合はステータスコード:400 バッドリクエストを返す" do
      post "/api/v1/users/password/request", params: used_email_attributes
      expect(response).to have_http_status(:bad_request)
    end

    it "既に使用されているメールアドレスの場合はエラーを返す" do
      post "/api/v1/users/password/request", params: used_email_attributes
      expect(JSON.parse(response.body)).to have_key("error")
    end

    it "メール送信に失敗したの場合はステータスコード:500 サーバーエラーを返す" do
      allow(PasswordResetMailer).to receive(:password_reset_email).with(valid_attributes).and_raise("メール送信エラー")
      post "/api/v1/users/password/request", params: valid_attributes
      expect(response).to have_http_status(:internal_server_error)
    end

    it "メール送信に失敗したの場合はエラーを返す" do
      allow(PasswordResetMailer).to receive(:password_reset_email).with(valid_attributes).and_raise("メール送信エラー")
      post "/api/v1/users/password/request", params: valid_attributes
      expect(JSON.parse(response.body)).to have_key("error")
    end
  end

  describe "PUT /api/v1/users/password reset_password" do
    let(:valid_attributes) { { email: "test@example.com", password: "Reseted Password" } }
    let(:invalid_attributes) { { email: "", password: "" } }
    let(:unused_email_attributes) { { email: "unused@example.com", password: "password" } }

    it "パスワードの更新に成功した場合はステータスコード:200 OKを返す" do
      put "/api/v1/users/password", params: valid_attributes
      expect(response).to have_http_status(:ok)
    end

    it "未使用のメールアドレスの場合はステータスコード:400 バッドリクエストを返す" do
      put "/api/v1/users/password", params: unused_email_attributes
      expect(response).to have_http_status(:bad_request)
    end

    it "未使用のメールアドレスの場合はエラーを返す" do
      put "/api/v1/users/password", params: unused_email_attributes
      expect(JSON.parse(response.body)).to have_key("error")
    end

    it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
      put "/api/v1/users/password", params: invalid_attributes
      expect(response).to have_http_status(:bad_request)
    end

    it "無効な入力の場合はレスポンスにエラーが含まれる" do
      put "/api/v1/users/password", params: invalid_attributes
      expect(JSON.parse(response.body)).to have_key("error")
    end
  end

  describe "PUT /api/v1/users/me/email update_current_user_email" do
    let(:valid_attributes) { { email: "updated@example.com" } }
    let(:invalid_attributes) { { email: "" } }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "メールアドレスの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/users/me/email", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "メールアドレスの更新に成功した場合はレスポンスにユーザが含まれる" do
        put "/api/v1/users/me/email", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("user")
      end

      it "メールアドレスの更新に成功" do
        put "/api/v1/users/me/email", params: valid_attributes
        expect(user.reload.email).to eq "updated@example.com"
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/users/me/email", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/users/me/email", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/email", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/email", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "PUT /api/v1/users/me/name update_current_user_name" do
    let(:valid_attributes) { { username: "Updated User" } }
    let(:invalid_attributes) { { username: "" } }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "メールアドレスの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/users/me/name", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "メールアドレスの更新に成功した場合はレスポンスにユーザが含まれる" do
        put "/api/v1/users/me/name", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("user")
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/users/me/name", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/users/me/name", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/name", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/name", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "PUT /api/v1/users/me/password update_current_user_password" do
    let(:valid_attributes) { { current_password: "password", new_password: "new password" } }
    let(:invalid_attributes) { { current_password: "", new_password: "" } }
    let(:wrong_password_attributes) { { current_password: "wrong password", new_password: "new password" } }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "パスワードの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/users/me/password", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "パスワードの更新に成功した場合はレスポンスにユーザが含まれる" do
        put "/api/v1/users/me/password", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("user")
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/users/me/password", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/users/me/password", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "パスワードが異なる場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/users/me/password", params: wrong_password_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "現在のパスワードが異なる場合はレスポンスにエラーが含まれる" do
        put "/api/v1/users/me/password", params: wrong_password_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/password", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        put "/api/v1/users/me/password", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "DELETE /api/v1/users/me destroy" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "ユーザの削除に成功した場合はステータスコード:200 OKを返す" do
        delete "/api/v1/users/me"
        expect(response).to have_http_status(:ok)
      end

      it "ユーザの削除に成功" do
        expect {
          delete "/api/v1/users/me"
        }.to change { User.count }.by(-1)
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        delete "/api/v1/users/me"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        delete "/api/v1/users/me"
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はユーザの削除をしない" do
        expect {
          delete "/api/v1/users/me"
        }.to change { User.count }.by(0)
      end
    end
  end
end
