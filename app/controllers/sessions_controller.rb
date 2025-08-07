class SessionsController < ApplicationController
  # Handles user login (authentication)
  def create
    # Find the user by username provided in the login form
    user = User.find_by(username: params[:username])

    # Check if the user exists and the password is correct
    if user&.authenticate(params[:password])
      # If valid, encode a JWT token with user_id
      token = jwt_encode(user_id: user.id)
      # Return the token as JSON to the frontend
      render json: { token: token }, status: :ok
    else
      # If authentication fails, return an error
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  private
  # Encodes the payload (including user_id and expiration) into a JWT token
  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i # Add expiration time to the payload
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
