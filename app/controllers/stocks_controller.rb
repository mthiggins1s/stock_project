require "faraday"

class StocksController < ApplicationController
  before_action :authenticate_request

  # GET /stocks
  def index
    request.format = :json
    symbols = %w[TSLA INTC MSFT NFLX META AMD NVDA GOOG AMZN AAPL]
    api_key = ENV["POLYGON_API_KEY"]

    results = symbols.map do |symbol|
      response = Faraday.get(
        "https://api.polygon.io/v2/aggs/ticker/#{symbol}/prev",
        { apiKey: api_key }
      )

      if response.success?
        data = JSON.parse(response.body)
        result = data["results"]&.first

        {
          symbol: symbol,
          price: result ? result["c"] : nil,   # closing price
          open: result ? result["o"] : nil,
          high: result ? result["h"] : nil,
          low: result ? result["l"] : nil,
          close: result ? result["c"] : nil,
          change: result ? (result["c"] - result["o"]) : nil,
          change_percent: result && result["o"] ? ((result["c"] - result["o"]) / result["o"]) : nil,
          logo_url: "https://logo.clearbit.com/#{symbol.downcase}.com"
        }
      else
        { symbol: symbol, error: "API error" }
      end
    end

    render json: results
  end

  # GET /stocks/:id/candles
  def candles
    symbol = params[:id] # ✅ use :id, not :symbol
    api_key = ENV["POLYGON_API_KEY"]

    response = Faraday.get(
      "https://api.polygon.io/v2/aggs/ticker/#{symbol}/range/1/day/2024-01-01/2025-01-01",
      { apiKey: api_key }
    )

    if response.success?
      body = JSON.parse(response.body)
      render json: body["results"] || []
    else
      Rails.logger.error("Polygon API error for candles: #{response.status} #{response.body}")
      render json: { error: "Failed to fetch candles" }, status: :bad_request
    end
  end
end
