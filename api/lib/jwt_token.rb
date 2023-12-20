require "jwt"

module JwtToken
  def self.generate_email_token(email)
    secret_key = Settings.email_secret_key
    exp = Time.now.to_i + 3600 # 1時間後のUNIXタイムスタンプ

    payload = {
      email:,
      exp:,
    }

    JWT.encode(payload, secret_key, "HS256")
  end
end
