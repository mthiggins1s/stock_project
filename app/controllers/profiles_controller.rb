class ProfilesController < ApplicationController
  before_action :authenticate_request

  # GET /profiles/:username
  def show
    # Eager-load to avoid N+1 queries and ensure location comes with the user/profile
    user = User.includes(:profile, :location).find_by(username: params[:username])

    # Return 404 if user or profile is missing (prevents 500s)
    if user.nil? || user.profile.nil?
      return render json: { error: "profile not found" }, status: :not_found
    end

    # Serialize the profile using your blueprint (keeps response shape consistent)
    render json: ProfileBlueprint.render(user.profile, view: :normal), status: :ok
  end
end
