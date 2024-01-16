class Api::V1::UsersController < ApplicationController

  def index
    render json: { users: {} }, status: :ok
  end

  def send_email_reset_password
    user_input = UserPreSignUpInput.new(email: params[:email])

    unless user_input.valid?
      logger.error user_input.errors.full_messages
      render json: { error: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: user_input.email)
    unless user.present?
      logger.error "入力したメールアドレスは未登録です"
      return render json: { error: "入力したメールアドレスは未登録です" }, status: :bad_request
    end

    # レコードが存在する場合
    # メール送信の処理（MailSenderのロジックに依存）
    begin
      PasswordResetMailer.password_reset_email(email: user_input.email).deliver_now
    rescue => e
      logger.error "メールの送信に失敗しました"
      return render json: { error: "メールの送信に失敗しました" }, status: :internal_server_error
    end

    render json: {}, status: :ok
  end

  def reset_password
    user_input = PasswordResetInput.new(email: params[:email], password: params[:password])

    unless user_input.valid?
      logger.error user_input.errors.full_messages
      render json: { error: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: user_input.email)
    unless user.present?
      logger.error "ユーザが存在しません"
      return render json: { error: "ユーザが存在しません" }, status: :bad_request
    end

    if user.update(password: user_input.password)
      logger.info "パスワードの更新に成功"
      render json: {}, status: :ok
    else
      logger.info user.errors.full_messages
      render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
  end
end
