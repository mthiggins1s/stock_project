# app/controllers/portfolios_controller.rb
class PortfoliosController < ApplicationController
  before_action :authenticate_request # ✅ require JWT here

  # GET /portfolio
  def index
    stocks = @current_user.stocks

    api_key = ENV["POLYGON_API_KEY"] || Rails.application.credentials.dig(:polygon, :api_key)

    stocks.each do |stock|
      begin
        response = Faraday.get(
          "https://api.polygon.io/v2/aggs/ticker/#{stock.symbol}/prev",
          { apiKey: api_key }
        )

        if response.success?
          data = JSON.parse(response.body)
          price = data.dig("results", 0, "c") # "c" = close price
          stock.update!(current_price: price) if price.present?
        else
          Rails.logger.warn "Polygon API error for #{stock.symbol}: #{response.status}"
        end
      rescue => e
        Rails.logger.error "Failed to update #{stock.symbol}: #{e.message}"
      end
    end

    render json: StockBlueprint.render(stocks, view: :detailed), status: :ok
  end

  # POST /portfolio
  def create
    stock = Stock.find(params[:stock_id])
    unless @current_user.stocks.exists?(stock.id)
      @current_user.stocks << stock
    end
    render json: { message: "Added #{stock.symbol} to portfolio" }, status: :created
  end

  # DELETE /portfolio/:id
  def destroy
    stock = @current_user.stocks.find(params[:id])
    @current_user.stocks.delete(stock)
    head :no_content
  end
end
