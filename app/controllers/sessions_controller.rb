class SessionsController < ApplicationController
  def create
    # Allow login via username OR email
    user = User.find_by(username: params[:usernameOrEmail]) ||
           User.find_by(email: params[:usernameOrEmail])

    if user&.authenticate(params[:password])
      token = jwt_encode(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  private

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
