module JwtHandler
  extend ActiveSupport::Concern

  SECRET_KEY = Rails.application.secret_key_base.freeze

  def encode_jwt(payload, exp: 24.hours.from_now, secret_key: SECRET_KEY)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, "HS256")
  end

  def decode_jwt(token, secret_key: SECRET_KEY)
    decoded = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
    decoded[0].with_indifferent_access
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end
