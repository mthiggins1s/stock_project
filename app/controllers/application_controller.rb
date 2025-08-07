class ApplicationController < ActionController::API
  # This method is used to protect routes that require authentication
  def authenticate_request
    # Get the 'Authorization' header from the incoming HTTP request
    header = request.headers["Authorization"]
    # If the header exists, split it to extract the JWT token (usually in the format 'Bearer token')
    header = header.split(" ").last if header

    begin
      # Decode the JWT using your Rails app's secret key
      # Returns the payload (the first element), which includes the user_id
      decoded = JWT.decode(header, Rails.application.secret_key_base).first
      # Find the user based on the user_id in the token
      @current_user = User.find(decoded["user_id"])
    rescue JWT::ExpiredSignature
      # Handle case where the token is expired
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError
      # Handle invalid token or decoding errors
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
