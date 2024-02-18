require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let!(:user_group) { UserGroup.create!(name: "Example Group") }
  let!(:user) { User.create!(name: "TestUser", email: "test@example.com", password: "password", password_confirmation: "password", user_group:) }
  let!(:category) { Category.create!(category: "Example Category", user_group:) }
  let!(:task) {
    Task.create!(task: "Task",
                 description: "Task Description",
                 creator: user,
                 category:,
                 status: 1,
                 responsible: user,
                 estimate: 3,
                 start_date: Time.zone.now)
  }

  describe "GET /api/v1/tasks/task-board task_board_index" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの取得に成功した場合はステータスコード:200 OKを返す" do
        get "/api/v1/tasks/task-board"
        expect(response).to have_http_status(:ok)
      end

      it "タスクの取得に成功した場合はレスポンスにタスクが含まれる" do
        get "/api/v1/tasks/task-board"
        expect(JSON.parse(response.body)).to have_key("tasks")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        get "/api/v1/tasks/task-board"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        get "/api/v1/tasks/task-board"
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "GET /api/v1/tasks/look-back look_back_index" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの取得に成功した場合はステータスコード:200 OKを返す" do
        get "/api/v1/tasks/look-back"
        expect(response).to have_http_status(:ok)
      end

      it "タスクの取得に成功した場合はレスポンスにタスクが含まれる" do
        get "/api/v1/tasks/look-back"
        expect(JSON.parse(response.body)).to have_key("tasks")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        get "/api/v1/tasks/look-back"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        get "/api/v1/tasks/look-back"
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "POST /api/v1/tasks create" do
    let(:valid_attributes) {
      {
        ID: "0",
        Task: "Created Task",
        Description: "Description",
        StartDate: Time.zone.now.to_i,
        Estimate: 10,
        Responsible: user.id,
        Status: 1,
        Category: category.id,
      }
    }

    let(:invalid_attributes) {
      {
        ID: "",
        Task: "",
        Description: "",
        StartDate: "",
        Estimate: "",
        Responsible: "",
        Status: "",
        Category: "",
      }
    }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの作成に成功した場合はステータスコード:200 OKを返す" do
        post "/api/v1/tasks", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "タスクの作成に成功した場合はレスポンスにタスクが含まれる" do
        post "/api/v1/tasks", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "タスクの作成に成功" do
        expect {
          post "/api/v1/tasks", params: valid_attributes
        }.to change { Task.count }.by(1)
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        post "/api/v1/tasks/", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        post "/api/v1/tasks/", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        post "/api/v1/tasks", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        post "/api/v1/tasks", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "タスクの作成に失敗" do
        expect {
          post "/api/v1/tasks", params: valid_attributes
        }.to change { Task.count }.by(0)
      end
    end
  end

  describe "PUT /api/v1/tasks update" do
    let(:valid_attributes) {
      {
        ID: task.id,
        Task: "Updated Task",
        Description: "Description",
        StartDate: Time.zone.now.to_i,
        Estimate: 10,
        Responsible: user.id,
        Status: 1,
        Category: category.id,
      }
    }

    let(:invalid_attributes) {
      {
        ID: "",
        Task: "",
        Description: "",
        StartDate: "",
        Estimate: "",
        Responsible: "",
        Status: "",
        Category: "",
      }
    }

    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
      end

      it "タスクの更新に成功した場合はレスポンスにタスクが含まれる" do
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "タスクの更新に成功" do
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(task.reload.task).to eq "Updated Task"
      end

      it "無効な入力の場合はステータスコード:400 バッドリクエストを返す" do
        put "/api/v1/tasks/#{task.id}", params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end

      it "無効な入力の場合はレスポンスにエラーが含まれる" do
        put "/api/v1/tasks/#{task.id}", params: invalid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "タスクの更新に失敗" do
        put "/api/v1/tasks/#{task.id}", params: valid_attributes
        expect(task.reload.task).to eq "Task"
      end
    end
  end

  describe "PUT /api/v1/tasks update_to_completed" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの更新に成功した場合はステータスコード:200 OKを返す" do
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(response).to have_http_status(:ok)
      end

      it "タスクの更新に成功した場合はレスポンスにタスクが含まれる" do
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "タスクのステータスの更新に成功" do
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(task.reload.status).to eq 4
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "タスクのステータスの更新に失敗" do
        put "/api/v1/tasks/#{task.id}/to-completed"
        expect(task.reload.status).to eq 1
      end
    end
  end

  describe "POST /api/v1/tasks delete" do
    context "ログインしてる場合" do
      before do
        cookies[:access_token] = JwtToken.generate_session_token(user.id)
      end

      it "タスクの削除に成功した場合はステータスコード:200 OKを返す" do
        delete "/api/v1/tasks/#{task.id}"
        expect(response).to have_http_status(:ok)
      end

      it "タスクの削除に成功した場合はレスポンスにタスクが含まれる" do
        delete "/api/v1/tasks/#{task.id}"
        expect(JSON.parse(response.body)).to have_key("tasks")
      end

      it "タスクの削除に成功" do
        expect {
          delete "/api/v1/tasks/#{task.id}"
        }.to change { Task.count }.by(-1)
      end
    end

    context "ログインしていない場合" do
      it "クッキーからユーザIDの抽出に失敗した場合はステータスコード:401 未認証を返す" do
        cookies.delete(:access_token)
        delete "/api/v1/tasks/#{task.id}"
        expect(response).to have_http_status(:unauthorized)
      end

      it "クッキーからユーザIDの抽出に失敗した場合はレスポンスにエラーが含まれる" do
        cookies.delete(:access_token)
        delete "/api/v1/tasks/#{task.id}"
        expect(JSON.parse(response.body)).to have_key("error")
      end

      it "タスクの削除に失敗" do
        expect {
          delete "/api/v1/tasks/#{task.id}"
        }.to change { Task.count }.by(0)
      end
    end
  end
end
