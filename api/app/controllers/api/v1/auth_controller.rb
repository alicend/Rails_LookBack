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
      # ここでメール送信のロジックを実行
      # MailSender.send_sign_up_mail(user_pre_sign_up_params[:email])
      AuthMailer.sign_up_email(email: user_input.email).deliver_now
    rescue => e
      return render json: { error: "メールの送信に失敗しました: #{e.message}" }, status: :internal_server_error
    end

    render json: {}, status: :ok
  end
end
