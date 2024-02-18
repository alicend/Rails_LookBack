require "rails_helper"

RSpec.describe "UserGroups", type: :request do
  let!(:user_group) { UserGroup.create!(name: "Example Group") }
  let!(:user) { User.create!(name: "TestUser", email: "test@example.com", password: "password", password_confirmation: "password", user_group:) }

  describe "PUT /api/v1/user-groups/:id update" do
    let(:valid_attributes) { { userGroup: "Updated Group" } }
    let(:invalid_attributes) { { userGroup: "" } }
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "ユーザグループの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "ユーザグループの更新に成功した場合はレスポンスにユーザが含まれる" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("user")
      end

      it "ユーザグループの更新に成功" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(user_group.reload.name).to eq "Updated Group"
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/user-groups/#{user_group.id}", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/user-groups/#{user_group.id}", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はユーザグループの更新しない" do
        put "/api/v1/user-groups/#{user_group.id}", params: valid_attributes
        expect(user_group.reload.name).to eq "Example Group"
      end
    end
  end

  describe "DELETE /api/v1/user-groups/:id destroy" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "ユーザグループの削除に成功した場合はステータスコード:200 OKを返す" do
        delete "/api/v1/user-groups/#{user_group.id}"
        expect(response).to have_http_status(:ok)
      end

      it "ユーザグループの削除に成功" do
        expect {
          delete "/api/v1/user-groups/#{user_group.id}"
        }.to change { UserGroup.count }.by(-1)
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        delete "/api/v1/user-groups/#{user_group.id}"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        delete "/api/v1/user-groups/#{user_group.id}"
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はユーザグループの削除をしない" do
        expect {
          delete "/api/v1/user-groups/#{user_group.id}"
        }.to change { UserGroup.count }.by(0)
      end
    end
  end
end
