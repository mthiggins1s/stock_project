require "faraday"

class PortfoliosController < ApplicationController
  before_action :authenticate_request # ✅ require JWT

  # GET /portfolios
  def index
    portfolios = @current_user.portfolios.includes(:stock)

    api_key = ENV["POLYGON_API_KEY"] || Rails.application.credentials.dig(:polygon, :api_key)

    portfolios.each do |p|
      next if p.stock.nil? # ✅ skip bad rows

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
        Rails.logger.error "Failed to update #{p.stock&.symbol}: #{e.message}"
      end
    end

    render json: portfolios.as_json(
      only: [ :id, :shares, :avg_cost ],
      include: {
        stock: { only: [ :id, :symbol, :name, :current_price ] }
      }
    ), status: :ok
  end

  # POST /portfolios
  def create
    # Find or create the stock by symbol
    stock = Stock.find_or_create_by!(symbol: params[:portfolio][:symbol]) do |s|
      s.name = params[:portfolio][:name]
      s.current_price = params[:portfolio][:current_price]
    end

    # Check if the user already has this stock in portfolio
    portfolio = @current_user.portfolios.find_by(stock: stock)

    if portfolio
      # ✅ Update existing holding (add to shares and recalc avg cost)
      total_shares = portfolio.shares + params[:portfolio][:shares].to_i
      portfolio.avg_cost = (
        (portfolio.avg_cost * portfolio.shares + params[:portfolio][:avg_cost].to_f * params[:portfolio][:shares].to_i) / total_shares
      )
      portfolio.shares = total_shares
    else
      # ✅ Create a new holding
      portfolio = @current_user.portfolios.new(
        stock: stock,
        shares: params[:portfolio][:shares],
        avg_cost: params[:portfolio][:avg_cost]
      )
    end

    if portfolio.save
      render json: portfolio.as_json(
        only: [ :id, :shares, :avg_cost ],
        include: {
          stock: { only: [ :id, :symbol, :name, :current_price ] }
        }
      ), status: :created
    else
      render json: { errors: portfolio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /portfolios/:id
  def update
    portfolio = @current_user.portfolios.find(params[:id])

    if portfolio.update(portfolio_params)
      render json: portfolio.as_json(
        only: [ :id, :shares, :avg_cost ],
        include: {
          stock: { only: [ :id, :symbol, :name, :current_price ] }
        }
      ), status: :ok
    else
      render json: { errors: portfolio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:id
  def destroy
    portfolio = @current_user.portfolios.find(params[:id])
    portfolio.destroy
    head :no_content
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:stock_id, :shares, :avg_cost)
  end
end
