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
end
