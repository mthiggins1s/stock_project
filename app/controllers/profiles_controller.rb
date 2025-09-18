class ProfilesController < ApplicationController
  before_action :authenticate_request, except: [ :show, :show_public, :portfolio ]

  # GET /profiles/:username
  def show
    user = User.find_by(username: params[:username])
    return render json: { error: "User not found" }, status: :not_found unless user

    render json: ProfileBlueprint.render(user.profile)
  end

  # GET /profiles/public/:public_id
  def show_public
    user = User.find_by(public_id: params[:public_id])
    return render json: { error: "User not found" }, status: :not_found unless user

    render json: ProfileBlueprint.render(user.profile)
  end

  # GET /profiles/public/:public_id/portfolio
  def portfolio
    user = User.find_by(public_id: params[:public_id])
    return render json: { error: "User not found" }, status: :not_found unless user

    render json: StockBlueprint.render(user.stocks)
  end

  # GET /profile (current user)
  def current
    render json: ProfileBlueprint.render(@current_user.profile)
  end

  # PATCH/PUT /profile
  def update
    profile = @current_user.profile
    if profile.update(profile_params)
      render json: ProfileBlueprint.render(profile)
    else
      render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:bio, :avatar_url, :location_id)
  end
end
