class Api::V1::UsersController < ApplicationController

  def send_email_reset_password
    user_input = UserPreSignUpInput.new(email: params[:email])

    unless user_input.valid?
      render json: { errors: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: user_input.email)
    unless user.present?
      return render json: { error: "入力したメールアドレスは未登録です" }, status: :bad_request
    end

    # レコードが存在する場合
    # メール送信の処理（MailSenderのロジックに依存）
    begin
      PasswordResetMailer.password_reset_email(email: user_input.email).deliver_now
    rescue => e
      return render json: { error: "メールの送信に失敗しました" }, status: :internal_server_error
    end

    render json: {}, status: :ok
  end

  def reset_password
    user_input = UserSignUpInput.new(email: params[:email], password: params[:password])

    unless user_input.valid?
      render json: { errors: user_input.errors.full_messages }, status: :bad_request
      return
    end

    # メールアドレスが登録済みか確認
    user = User.find_by(email: user_input.email)
    unless user.present?
      return render json: { error: "ユーザが存在しません" }, status: :bad_request
    end

    if user.update(password: user_input.password)
      logger.info "パスワードの更新に成功"
      render json: {}, status: :ok
    else
      render json: { error: "" }, status: :internal_server_error
    end
  end
end
