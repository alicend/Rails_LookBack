require "rails_helper"

RSpec.describe "Categories", type: :request do
  let!(:user_group) { UserGroup.create!(name: "Example Group") }
  let!(:user) { User.create!(name: "TestUser", email: "test@example.com", password: "password", password_confirmation: "password", user_group:) }
  let!(:category) { Category.create!(category: "Example Category", user_group:) }

  describe "GET /api/v1/categories index" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "カテゴリーの取得に成功した場合はステータスコード:200 OKを返す" do
        get "/api/v1/categories"
        expect(response).to have_http_status(:ok)
      end

      it "カテゴリーの取得に成功した場合はレスポンスにカテゴリーが含まれる" do
        get "/api/v1/categories"
        expect(JSON.parse(response.body)).to have_key("categories")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        get "/api/v1/categories"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        get "/api/v1/categories"
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "POST /api/v1/categories create" do
    let(:valid_attributes) { { category: "Created Category" } }
    let(:invalid_attributes) { { category: "" } }
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "カテゴリーの作成に成功した場合はステータスコード:200 OKを返す" do
        post "/api/v1/categories", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "カテゴリーの作成に成功した場合はレスポンスにカテゴリーが含まれる" do
        post "/api/v1/categories", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("categories")
      end

      it "カテゴリーの作成に成功" do
        expect {
          post "/api/v1/categories", params: valid_attributes
        }.to change { Category.count }.by(1)
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        post "/api/v1/categories", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        post "/api/v1/categories", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        post "/api/v1/categories", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        post "/api/v1/categories", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はカテゴリーの作成しない" do
        expect {
          post "/api/v1/categories", params: valid_attributes
        }.to change { Category.count }.by(0)
      end
    end
  end

  describe "PUT /api/v1/categories/:id update" do
    let(:valid_attributes) { { category: "Updated Category" } }
    let(:invalid_attributes) { { category: "" } }
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "カテゴリーの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "カテゴリーの更新に成功した場合はレスポンスにカテゴリーが含まれる" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("categories")
      end

      it "カテゴリーの更新に成功した場合はレスポンスにタスクが含まれる" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "カテゴリーの更新に成功" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(category.reload.category).to eq "Updated Category"
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/categories/#{category.id}", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/categories/#{category.id}", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はカテゴリーの更新しない" do
        put "/api/v1/categories/#{category.id}", params: valid_attributes
        expect(category.reload.category).to eq "Example Category"
      end
    end
  end

  describe "DELETE /api/v1/categories/:id destroy" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "カテゴリーの削除に成功した場合はステータスコード:200 OKを返す" do
        delete "/api/v1/categories/#{category.id}"
        expect(response).to have_http_status(:ok)
      end

      it "カテゴリーの削除に成功した場合はレスポンスにカテゴリーが含まれる" do
        delete "/api/v1/categories/#{category.id}"
        expect(JSON.parse(response.body)).to have_key("categories")
      end

      it "カテゴリーの削除に成功した場合はレスポンスにタスクが含まれる" do
        delete "/api/v1/categories/#{category.id}"
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "カテゴリーの削除に成功" do
        expect {
          delete "/api/v1/categories/#{category.id}"
        }.to change { Category.count }.by(-1)
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        delete "/api/v1/categories/#{category.id}"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        delete "/api/v1/categories/#{category.id}"
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "クッキーからユーザIDの抽出に失敗した場合はカテゴリーの削除をしない" do
        expect {
          delete "/api/v1/categories/#{category.id}"
        }.to change { Category.count }.by(0)
      end
    end
  end
end
