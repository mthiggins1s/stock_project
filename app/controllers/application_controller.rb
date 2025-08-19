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
    # Extract "Bearer <token>" from Authorization header
    header = request.headers["Authorization"].to_s
    token  = header[/\ABearer (.+)\z/, 1]
    raise JWT::DecodeError, "missing token" if token.blank?

    # VERIFY signature and expiration
    payload = JWT.decode(
      token,
      Rails.application.secret_key_base,
      true, # verify signature
      { algorithm: "HS256", verify_expiration: true }
    ).first

    @current_user = User.find(payload["user_id"])
  end
end
