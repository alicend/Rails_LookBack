require "jwt"

module JwtToken
  def self.generate_email_token(email)
    secret_key = Settings.email_secret_key
    exp = Time.now.to_i + 24 * 3600 # 24時間後のUNIXタイムスタンプ

    payload = {
      email:,
      exp:,
    }

    JWT.encode(payload, secret_key, "HS256")
  end

  def self.generate_session_token(user_id)
    secret_key = Settings.session_secret_key
    exp = Time.now.to_i + 24 * 3600 # 24時間後のUNIXタイムスタンプ

    payload = {
      user_id:,
      exp:,
    }

    JWT.encode(payload, secret_key, "HS256")
  end

  def self.generate_user_group_id_token(user_group_id)
    secret_key = Settings.user_group_id_secret_key
    exp = Time.now.to_i + 24 * 3600 # 24時間後のUNIXタイムスタンプ

    payload = {
      user_group_id:,
      exp:,
    }

    JWT.encode(payload, secret_key, "HS256")
  end

  def self.parse_session_token(token_string)
    secret_key = Settings.session_secret_key
    JWT.decode(token_string, secret_key, true, { algorithm: "HS256" })
  rescue JWT::DecodeError => e
    Rails.logger.error e.message
    nil
  end
end
