class Api::V1::UsersController < ApplicationController
  before_action :authenticate, except: [:send_email_reset_password, :reset_password]

  def index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group_id = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group_id}")

    users = User.where(user_group_id: login_user_group_id).
              order(:name).
              select("id AS ID", "name AS Name")
    Rails.logger.info("ユーザのの取得に成功")

    render json: { users: }, status: :ok
  rescue => e
    Rails.logger.error("ユーザの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def current_user
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    user = User.left_joins(:user_group).
             select(
               "users.id AS ID",
               "users.email AS Email",
               "users.name AS Name",
               "users.user_group_id AS UserGroupID",
               "user_groups.name AS UserGroup",
             ).
             find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: }, status: :ok
  rescue => e
    Rails.logger.error("ログインユーザの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def send_update_email_email
    send_update_email_input = SendUpdateEmailInput.new(email: params[:email])

    unless send_update_email_input.valid?
      Rails.logger.error(send_update_email_input.errors.full_messages)
      render json: { error: send_update_email_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが既に使用されていないか確認
    user = User.find_by(email: send_update_email_input.email)
    if user.present?
      return render json: { error: "他のユーザーが使用しているので別のメールアドレスを入力してください" }, status: :bad_request
    end

    # メール送信の処理（MailSenderのロジックに依存）
    begin
      UpdateEmailMailer.update_email_email(email: send_update_email_input.email).deliver_now
    rescue => e
      logger.error e.message
      return render json: { error: "メールの送信に失敗しました: #{e.message}" }, status: :internal_server_error
    end

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    user = User.left_joins(:user_group).
             select(
               "users.id AS ID",
               "users.email AS Email",
               "users.name AS Name",
               "users.user_group_id AS UserGroupID",
               "user_groups.name AS UserGroup",
             ).
             find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: }, status: :ok
  end

  def send_email_reset_password
    password_pre_reset_input = PasswordPreResetInput.new(email: params[:email])

    unless password_pre_reset_input.valid?
      Rails.logger.error(password_pre_reset_input.errors.full_messages)
      render json: { error: password_pre_reset_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: password_pre_reset_input.email)
    if user.blank?
      logger.error "入力したメールアドレスは未登録です"
      return render json: { error: "入力したメールアドレスは未登録です" }, status: :bad_request
    end

    # レコードが存在する場合
    # メール送信の処理（MailSenderのロジックに依存）
    begin
      PasswordResetMailer.password_reset_email(email: password_pre_reset_input.email).deliver_now
    rescue => e
      logger.error e.message
      return render json: { error: "メールの送信に失敗しました" }, status: :internal_server_error
    end

    render json: {}, status: :ok
  end

  def reset_password
    password_reset_input = PasswordResetInput.new(email: params[:email], password: params[:password])

    unless password_reset_input.valid?
      Rails.logger.error(password_reset_input.errors.full_messages)
      logger.error password_reset_input.errors.full_messages
      render json: { error: password_reset_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: password_reset_input.email)
    if user.blank?
      logger.error "ユーザが存在しません"
      return render json: { error: "ユーザが存在しません" }, status: :bad_request
    end

    if user.update(password: password_reset_input.password)
      logger.info "パスワードの更新に成功"
      render json: {}, status: :ok
    else
      logger.info user.errors.full_messages
      render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
  end

  def update_current_user_email
    update_current_user_email_input = UpdateCurrentUserEmailInput.new(email: params[:email])

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # ログインユーザのユーザ名を更新
    user = User.find(login_user_id)
    user.update!(
      email: update_current_user_email_input.email,
    )
    Rails.logger.info("ログインユーザのメールアドレスの更新に成功")

    user = User.left_joins(:user_group).
             select(
               "users.id AS ID",
               "users.email AS Email",
               "users.name AS Name",
               "users.user_group_id AS UserGroupID",
               "user_groups.name AS UserGroup",
             ).
             find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: }, status: :ok
  rescue => e
    Rails.logger.error("ログインユーザのメールアドレスの更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_current_user_name
    update_current_user_name_input = UpdateCurrentUserNameInput.new(username: params[:username])

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # ログインユーザのユーザ名を更新
    user = User.find(login_user_id)
    user.update!(
      name: update_current_user_name_input.username,
    )
    Rails.logger.info("ログインユーザのユーザ名の更新に成功")

    user = User.left_joins(:user_group).
             select(
               "users.id AS ID",
               "users.email AS Email",
               "users.name AS Name",
               "users.user_group_id AS UserGroupID",
               "user_groups.name AS UserGroup",
             ).
             find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: }, status: :ok
  rescue => e
    Rails.logger.error("ログインユーザのユーザ名の更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_current_user_password
    update_current_user_password_input = UpdateCurrentUserPasswordInput.new(current_password: params[:current_password], new_password: params[:new_password])

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # 入力したパスワードが正しいか確認
    user = User.find(login_user_id)
    unless user.authenticate(update_current_user_password_input.current_password)
      render json: { error: "パスワードが違います" }, status: :bad_request
      return
    end

    # ログインユーザのパスワードを更新
    user.update!(
      password: update_current_user_password_input.new_password,
    )
    Rails.logger.info("ログインユーザのパスワードの更新に成功")

    user = User.left_joins(:user_group).
             select(
               "users.id AS ID",
               "users.email AS Email",
               "users.name AS Name",
               "users.user_group_id AS UserGroupID",
               "user_groups.name AS UserGroup",
             ).
             find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: }, status: :ok
  rescue => e
    Rails.logger.error("ログインユーザのパスワードの更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # ユーザを削除
    user = User.find(login_user_id)
    user.destroy!
    Rails.logger.info("ユーザの削除に成功")

    cookies.delete(:access_token, httponly: true, secure: true)
    cookies.delete(:guest_login, httponly: true, secure: true)

    render json: {}, status: :ok
  rescue => e
    Rails.logger.error("ユーザの削除に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
