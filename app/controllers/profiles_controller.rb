class ProfilesController < ApplicationController
  before_action :authenticate_request

  def show
    user = User.find_by(username: params[:username])
    profile = user.profile
    render json: ProfileBlueprint.render(profile, view: :normal), status: :ok
  end
end
