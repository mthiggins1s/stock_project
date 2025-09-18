class PortfoliosController < ApplicationController
  before_action :authenticate_request

  # GET /portfolios
  def index
    portfolio = @current_user.default_portfolio
    holdings = portfolio.portfolio_stocks.includes(:stock)

    api_key = ENV["POLYGON_API_KEY"] || Rails.application.credentials.dig(:polygon, :api_key)

    holdings.each do |holding|
      stock = holding.stock
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

    render json: holdings.as_json(
      include: { stock: { only: [ :id, :symbol, :name, :current_price ] } },
      only: [ :id, :shares, :avg_cost ]
    ), status: :ok
  end

  # POST /portfolios
  def create
    Rails.logger.debug "📩 Incoming params for portfolio#create: #{params.inspect}"

    begin
      stock_params = params.require(:portfolio).permit(:symbol, :name, :current_price, :shares, :avg_cost)

      stock = Stock.find_or_create_by!(symbol: stock_params[:symbol]) do |s|
        s.name = stock_params[:name]
        s.current_price = stock_params[:current_price]
      end

      portfolio = @current_user.default_portfolio

      holding = portfolio.portfolio_stocks.find_or_initialize_by(stock: stock)
      holding.shares ||= stock_params[:shares] || 0
      holding.avg_cost ||= stock_params[:avg_cost] || stock_params[:current_price] || 0
      holding.save!

      Rails.logger.debug "✅ Added/updated holding for #{stock.symbol} in portfolio #{portfolio.id}"

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
    holding = portfolio.portfolio_stocks.find(params[:id])
    holding.destroy!

    Rails.logger.debug "✅ Removed holding #{holding.id} (#{holding.stock.symbol}) from portfolio #{portfolio.id}"

    head :no_content
  end
end
