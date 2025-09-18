class ApplicationController < ActionController::API
  # --- Uniform auth errors as JSON 401s ---
  rescue_from JWT::ExpiredSignature do
    render json: { error: "token expired" }, status: :unauthorized
  end

  rescue_from JWT::DecodeError do
    render json: { error: "unauthorized" }, status: :unauthorized
  end

  private

  # Call this in controllers as a before_action to protect endpoints
  def authenticate_request
    # Extract Authorization header
    header = request.headers["Authorization"].to_s
    Rails.logger.debug "🔎 Raw Authorization header: #{header.inspect}"

    # Normalize (case-insensitive, strip "Bearer ")
    token = header.to_s.sub(/^Bearer\s+/i, "").strip
    Rails.logger.debug "🔎 Extracted token: #{token.present? ? token[0..15] + '...' : 'nil'}"

    raise JWT::DecodeError, "missing token" if token.blank?

    # Decode + verify signature & expiration
    payload = JWT.decode(
      token,
      Rails.application.secret_key_base, # must match encoding secret
      true,                              # verify signature
      { algorithm: "HS256", verify_expiration: true }
    ).first

    Rails.logger.debug "✅ Decoded JWT payload: #{payload.inspect}"

    @current_user = User.find(payload["user_id"])
    Rails.logger.debug "✅ Authenticated user: #{@current_user.username} (ID=#{@current_user.id})"
  end
end
