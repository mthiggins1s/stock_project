class StocksController < ApplicationController
  before_action :authenticate_request, only: [ :portfolio_candles, :portfolio_summary ]

  SNAPSHOT_BASE   = "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers"
  AGGREGATES_BASE = "https://api.polygon.io/v2/aggs/ticker"

  # GET /stocks
  def index
    symbols = %w[AAPL MSFT TSLA AMZN GOOG META NVDA NFLX AMD INTC]
    key = ENV["POLYGON_API_KEY"]

    response = Faraday.get("#{SNAPSHOT_BASE}?tickers=#{symbols.join(",")}&apiKey=#{key}")

    if response.success?
      data = JSON.parse(response.body)
      render json: data
    else
      render json: { error: "Failed to fetch stocks" }, status: :bad_request
    end
  end

  # GET /stocks/:id
  def show
    stock = Stock.find_by(id: params[:id]) || Stock.find_by(symbol: params[:id])
    if stock
      render json: StockBlueprint.render(stock)
    else
      render json: { error: "Stock not found" }, status: :not_found
    end
  end

  # GET /stocks/:id/candles
  def candles
    stock = Stock.find_by(symbol: params[:id])
    return render json: { error: "Stock not found" }, status: :not_found unless stock

    key = ENV["POLYGON_API_KEY"]
    response = Faraday.get("#{AGGREGATES_BASE}/#{stock.symbol}/range/1/day/2024-01-01/2024-12-31?apiKey=#{key}")

    if response.success?
      render json: JSON.parse(response.body)
    else
      render json: { error: "Failed to fetch candles" }, status: :bad_request
    end
  end

  # GET /portfolios/candles
  def portfolio_candles
    symbols = @current_user.stocks.pluck(:symbol)
    key = ENV["POLYGON_API_KEY"]

    results = symbols.map do |sym|
      response = Faraday.get("#{AGGREGATES_BASE}/#{sym}/range/1/day/2024-01-01/2024-12-31?apiKey=#{key}")
      [ sym, JSON.parse(response.body) ] if response.success?
    end.compact.to_h

    render json: results
  end

  # GET /portfolios/summary
  def portfolio_summary
    total_value = @current_user.stocks.sum(&:current_price)
    render json: { total_value: total_value }
  end
end
