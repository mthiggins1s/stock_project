class SessionsController < ApplicationController
  skip_before_action :authenticate_request

  def create
    # Support both flat params and nested session params
    login_params = params[:session] || params

    user = User.find_by(username: login_params[:usernameOrEmail]) ||
           User.find_by(email: login_params[:usernameOrEmail])

    if user&.authenticate(login_params[:password])
      token = jwt_encode(user_id: user.id)
      render json: { token: token, public_id: user.public_id }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
