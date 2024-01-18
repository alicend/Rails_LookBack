class Api::V1::UsersController < ApplicationController

  def index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group_id = UserGroup.joins(:users).where(users: { id: login_user_id }).select('user_groups.id').first
    Rails.logger.info("ログインユーザグループID : #{login_user_group_id}")

    users = User.where(user_group_id: login_user_group_id)
              .order(:name)
              .select('id AS ID', 'name AS Name')
    Rails.logger.info("ユーザのの取得に成功")

    render json: { users: users }, status: :ok
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

    user = User.left_joins(:user_group)
              .select(
                'users.id AS ID',
                'users.email AS Email',
                'users.name AS Name',
                'users.user_group_id AS UserGroupID',
                'user_groups.name AS UserGroup',
                )
                .find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: user }, status: :ok
  rescue => e
    Rails.logger.error("ログインユーザの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def send_update_email_email
    send_update_email_input = SendUpdateEmailInput.new(email: params[:email])

    unless send_update_email_input.valid?
      Rails.logger.error(send_update_email_input.errors.full_messages)
      render json: { errors: send_update_email_input.errors.full_messages }, status: :bad_request
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

    user = User.left_joins(:user_group)
              .select(
                'users.id AS ID',
                'users.email AS Email',
                'users.name AS Name',
                'users.user_group_id AS UserGroupID',
                'user_groups.name AS UserGroup',
                )
                .find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: user }, status: :ok
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
    unless user.present?
      logger.error "入力したメールアドレスは未登録です"
      return render json: { error: "入力したメールアドレスは未登録です" }, status: :bad_request
    end

    # レコードが存在する場合
    # メール送信の処理（MailSenderのロジックに依存）
    begin
      PasswordResetMailer.password_reset_email(email: password_pre_reset_input.email).deliver_now
    rescue => e
      logger.error "メールの送信に失敗しました"
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
    unless user.present?
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
end
