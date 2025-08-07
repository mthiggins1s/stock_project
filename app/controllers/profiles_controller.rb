class ProfilesController < ApplicationController
  # Ensure user is authenticated before allowing access to any actions in this controller
  before_action :authenticate_request

  def show
    # Find user by username provided in URL parameters (e.g., /profiles/:username)
    user = User.find_by(username: params[:username])
    # Get the profile associated with this user
    profile = user.profile
    # Render the profile as JSON using the ProfileBlueprint serializer
    render json: ProfileBlueprint.render(profile, view: :normal), status: :ok
  end
end
