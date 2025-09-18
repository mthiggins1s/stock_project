class UsersController < ApplicationController
  # Do NOT require JWT for creating a user
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    user = User.new(user_params)
    if user.save
      render json: UserBlueprint.render(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    user = User.find_by(public_id: params[:id]) || User.find_by(username: params[:id])
    if user
      render json: UserBlueprint.render(user)
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def me
    render json: UserBlueprint.render(@current_user)
  end

  private

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :email, :password)
  end
end
