require "faraday"

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
    portfolios = user.portfolios.includes(:stock)

    if portfolios.empty?
      return render json: { error: "portfolio not found" }, status: :not_found
    end

    api_key = ENV["POLYGON_API_KEY"] || Rails.application.credentials.dig(:polygon, :api_key)

    # 🔄 Update prices from Polygon
    portfolios.each do |p|
      next unless p.stock&.symbol.present?

      begin
        response = Faraday.get(
          "https://api.polygon.io/v2/aggs/ticker/#{p.stock.symbol}/prev",
          { apiKey: api_key }
        )

        if response.success?
          data = JSON.parse(response.body)
          price = data.dig("results", 0, "c") # "c" = close price
          p.stock.update!(current_price: price) if price.present?
        else
          Rails.logger.warn "Polygon API error for #{p.stock.symbol}: #{response.status}"
        end
      rescue => e
        Rails.logger.error "Failed to update #{p.stock.symbol}: #{e.message}"
      end
    end

    # 🛠 Ensure numeric values so frontend never sees null
    render json: portfolios.map { |p|
      {
        id: p.id,
        shares: p.shares || 0,
        avg_cost: p.avg_cost.to_f || 0.0,
        stock: {
          id: p.stock.id,
          symbol: p.stock.symbol,
          name: p.stock.name,
          current_price: p.stock.current_price.to_f || 0.0
        }
      }
    }, status: :ok
  end
end
