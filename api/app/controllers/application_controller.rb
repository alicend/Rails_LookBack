class ApplicationController < ActionController::API
  include ActionController::Cookies

  protected

    # CookieからユーザーIDを抽出する
    def extract_user_id
      token = cookies[:access_token]
      return nil if token.blank?

      begin
        decoded_token = JwtToken.parse_session_token(token)
        user_id = decoded_token[0]["user_id"]
        user_id ? user_id.to_i : nil
      rescue => e
        Rails.logger.error("Failed to extract user ID: #{e.message}")
        nil
      end
    end

    def authenticate
      token = cookies[:access_token]
      if token.blank?
        Rails.logger.error("認証情報が存在しません")
        render json: { error: "Authentication token is missing" }, status: :unauthorized and return
      end

      begin
        decoded_token = JwtToken.parse_session_token(token)
        user_id = decoded_token[0]["user_id"]
        if user_id.blank?
          Rails.logger.error("認証情報が正しくありません")
          render json: { error: "Invalid authentication token" }, status: :unauthorized and return
        end
      rescue => e
        Rails.logger.error("認証情報の解析に失敗しました: #{e.message}")
        render json: { error: e.message }, status: :unauthorized and return
      end
    end
end
