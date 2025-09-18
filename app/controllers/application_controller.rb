class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :set_default_format
  before_action :authenticate_request

  private

  def set_default_format
    request.format = :json
  end

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

  def authenticate_request
  header = request.headers["Authorization"]
  token  = header.split(" ").last if header.present?

  decoded = jwt_decode(token)
  Rails.logger.debug "Decoded JWT: #{decoded.inspect}"

  if decoded
    user_id = decoded[:user_id] || decoded["user_id"]
    Rails.logger.debug "Trying to find user with id=#{user_id}"
    @current_user = User.find_by(id: user_id)
    Rails.logger.debug "Current User: #{@current_user.inspect}"
  end

  # binding.break   # 👈 this pauses execution in Rails 7/8 with the debug gem

  render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
  end
end
