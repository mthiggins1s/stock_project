class PortfoliosController < ApplicationController
  before_action :authenticate_request

  # GET /portfolios
  def index
    portfolio = @current_user.default_portfolio
    stocks = portfolio.stocks

    api_key = ENV["POLYGON_API_KEY"] || Rails.application.credentials.dig(:polygon, :api_key)

    stocks.each do |stock|
      begin
        response = Faraday.get(
          "https://api.polygon.io/v2/aggs/ticker/#{stock.symbol}/prev",
          { apiKey: api_key }
        )

        if response.success?
          data = JSON.parse(response.body)
          price = data.dig("results", 0, "c")
          stock.update!(current_price: price) if price.present?
        else
          Rails.logger.warn "⚠️ Polygon API error for #{stock.symbol}: #{response.status}"
        end
      rescue => e
        Rails.logger.error "❌ Failed to update #{stock.symbol}: #{e.message}"
      end
    end

    render json: stocks.as_json(only: [ :id, :symbol, :name, :current_price ]), status: :ok
  end

  # POST /portfolios
  def create
    Rails.logger.debug "📩 Incoming params for portfolio#create: #{params.inspect}"

    begin
      stock_params = params.require(:portfolio).permit(:symbol, :name, :current_price)

      stock = Stock.find_or_create_by!(symbol: stock_params[:symbol]) do |s|
        s.name = stock_params[:name]
        s.current_price = stock_params[:current_price]
      end

      portfolio = @current_user.default_portfolio

      unless portfolio.stocks.exists?(stock.id)
        portfolio.stocks << stock
        Rails.logger.debug "✅ Added stock #{stock.symbol} to portfolio #{portfolio.id}"
      else
        Rails.logger.debug "ℹ️ Stock #{stock.symbol} already in portfolio #{portfolio.id}"
      end

      render json: { message: "Added #{stock.symbol} to portfolio" }, status: :created
    rescue ActionController::ParameterMissing => e
      Rails.logger.error "❌ Missing parameters: #{e.message}"
      render json: { error: "Invalid params", details: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "❌ Unexpected error in portfolio#create: #{e.message}"
      render json: { error: "Failed to add stock", details: e.message }, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:id
  def destroy
    Rails.logger.debug "🗑 Incoming params for portfolio#destroy: #{params.inspect}"

    portfolio = @current_user.default_portfolio
    stock = portfolio.stocks.find(params[:id])
    portfolio.stocks.delete(stock)

    Rails.logger.debug "✅ Removed stock #{stock.symbol} from portfolio #{portfolio.id}"

    head :no_content
  end
end
