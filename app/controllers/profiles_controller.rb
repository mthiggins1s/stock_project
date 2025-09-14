class ProfilesController < ApplicationController
  before_action :authenticate_request, except: [ :show_public, :portfolio ]

  # GET /profiles/:username
  def show
    user = User.includes(:profile, :location).find_by(username: params[:username])

    if user.nil? || user.profile.nil?
      return render json: { error: "profile not found" }, status: :not_found
    end

    render json: ProfileBlueprint.render(user.profile, view: :normal), status: :ok
  end

  # GET /profiles/public/:public_id
  def show_public
    user = User.find_by!(public_id: params[:public_id])
    render json: {
      public_id: user.public_id,
      created_at: user.created_at
    }
  end

  # GET /profiles/public/:public_id/portfolio
  def portfolio
    user = User.find_by!(public_id: params[:public_id])
    stocks = Stock.joins(:portfolios).where(portfolios: { user_id: user.id }).distinct

    render json: StockBlueprint.render(stocks)
  end
end
