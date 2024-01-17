class Api::V1::AuthController < ApplicationController
  def send_sign_up_email
    user_input = UserPreSignUpInput.new(email: params[:email])

    unless user_input.valid?
      render json: { errors: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが既に使用されていないか確認
    user = User.find_by(email: user_input.email)
    if user.present?
      return render json: { error: "他のユーザーが使用しているので別のメールアドレスを入力してください" }, status: :bad_request
    end

    # メール送信の処理（MailSenderのロジックに依存）
    begin
      AuthMailer.sign_up_email(email: user_input.email).deliver_now
    rescue => e
      logger.error e.message
      return render json: { error: "メールの送信に失敗しました: #{e.message}" }, status: :internal_server_error
    end

    render json: {}, status: :ok
  end

  def create
    user_input = UserSignUpInput.new(sign_up_params)

    unless user_input.valid?
      logger.error user_input.errors.full_messages
      render json: { error: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # 新しいUserGroupを作成
    user_group = UserGroup.new(name: user_input.user_group)
    unless user_group.save
      logger.error user_group.errors.full_messages
      return render json: { error: user_group.errors.full_messages }, status: :internal_server_error
    end

    # 新しいユーザーを作成
    user = User.new(
      name: user_input.username,
      password: user_input.password,
      email: user_input.email,
      user_group_id: user_group.id,
    )
    unless user.save
      logger.error user.errors.full_messages
      return render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
    render json: { user_id: user.id, message: "Successfully created user" }, status: :ok if user.save
  end

  def login
    login_input = LoginInput.new(login_params)

    unless login_input.valid?
      logger.error login_input.errors.full_messages
      render json: { error: login_input.errors.full_messages }, status: :bad_request
      return
    end

    user = User.find_by_email(login_input.email)
    if user.nil?
      render json: { error: '存在しないユーザです' }, status: :not_found
      return
    end

    unless user.authenticate(login_input.password)
      render json: { error: 'パスワードが違います' }, status: :unauthorized
      return
    end

    begin
      token = JwtToken.generate_session_token(user)
      cookies.signed[:jwt_token] = { value: token, httponly: true, domain: Settings.front_domain }
      cookies.signed[:guest_login] = { value: false, httponly: true, domain: Settings.front_domain }
    rescue => e
      logger.error e.message
      return render json: { error: e.message }, status: :bad_request
    end

    render json: {}, status: :ok
  end

  def guest_login
    unless delete_guest_user
      return render json: { error: "ゲストログインに失敗しました" }, status: :internal_server_error
    end

    user = create_guest_user

    unless user
      return render json: { error: "ゲストログインに失敗しました" }, status: :internal_server_error
    end

    begin
      token = JwtToken.generate_session_token(user.id)
      cookies[:access_token] = { value: token, httponly: true, secure: true }
      cookies[:guest_login] = { value: "true", httponly: false, secure: true }
    rescue => e
      logger.error e.message
      return render json: { error: e.message }, status: :bad_request
    end

    return render json: {}, status: :ok
  end

  def logout
    cookies.delete(:access_token, httponly: true, secure: true)
    cookies.delete(:guest_login, httponly: true, secure: true)

    render json: {}, status: :ok
  end

  private

  def sign_up_params
    params.require(:auth).permit(:email, :password, :username, :user_group)
  end

  def login_params
    params.require(:auth).permit(:email, :password)
  end

  def create_guest_user

    users = nil # 初期化

    ActiveRecord::Base.transaction do
      # UserGroupの作成
      user_group = UserGroup.create!(id: 0, name: "開発部")

      # Usersの作成
      users = User.create!([
        { name: "山田太郎", password: "password123", email: "yamada@example.com", user_group: user_group },
        { name: "佐藤花子", password: "password456", email: "sato@example.com", user_group: user_group },
        { name: "鈴木一郎", password: "password789", email: "suzuki@example.com", user_group: user_group }
      ])

      # Categoriesの作成
      categories = Category.create!([
        { category: "バグ修正", user_group: user_group },
        { category: "新機能", user_group: user_group }
      ])

      # Tasksの作成
      tasks = Task.create!([
        {
        task: "認証問題の修正",
        description: "アップデート後にログインできない",
        creator: users.first,
        category: categories.first,
        status: 1,
        responsible: users.first,
        estimate: 3,
        start_date: Time.now + 1.day
      },
      {
        task: "新しいマーケティングキャンペーンの立ち上げ",
        description: "夏のセール向けマーケティング",
        creator: users.first,
        category: categories.second,
        status: 2,
        responsible: users.second,
        estimate: 10,
        start_date: Time.now + 1.month
      },
      {
        task: "財務監査",
        description: "最後の四半期の監査",
        creator: users.first,
        category: categories.second,
        status: 3,
        responsible: users.second,
        estimate: 15,
        start_date: Time.now + 7.day
      },
      {
        task: "新規機能の開発",
        description: "ユーザーインターフェースの改善",
        creator: users.second,
        category: categories.first,
        status: 4,
        responsible: users.first,
        estimate: 5,
        start_date: Time.now - 6.day
    }
      ])
    end
    Rails.logger.info "ゲストユーザーの作成に成功"
    return users.first

  rescue ActiveRecord::RecordInvalid => e
    # エラーログ出力
    Rails.logger.error "エラー: #{e.message}"
    return false
  end

  def delete_guest_user
    ActiveRecord::Base.transaction do
      # UserGroupIDが0であるUserのIDを取得
      user_ids = User.where(user_group_id: 0).pluck(:id)

      # 取得したUser IDsに紐づくTaskを削除
      Task.where(creator: user_ids).or(Task.where(responsible: user_ids)).delete_all

      # UserGroupIDが0であるCategoryを削除
      Category.where(user_group_id: 0).delete_all

      # UserGroupIDが0であるUserを削除
      User.where(user_group_id: 0).delete_all

      # 最後にIDが0であるUserGroupを削除
      UserGroup.where(id: 0).delete_all

    end

    return true
  rescue => e
    Rails.logger.error "Error in deleting guest users: #{e.message}"
    # トランザクションのロールバックを明示的に指示
    raise ActiveRecord::Rollback
    return false
  end

end
