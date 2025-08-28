require "net/http"
require "uri"
require "json"

class StocksController < ApplicationController
  BASE_URL = "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers"
  USE_MOCK = false # 🔥 flip to true for fake prices during dev

  # GET /stocks
  def index
    request.format = :json
    symbols = %w[AAPL TSLA MSFT AMZN GOOG]
    key = ENV["POLYGON_API_KEY"] || "0Q7EjcdhNI7i3bPbJ5Vg5usCKhocBNFV"

    if USE_MOCK
      stocks = symbols.map { |s| { symbol: s, price: rand(100..500) + rand.round(2), mock: true } }
      render json: stocks and return
    end

    stocks = symbols.map do |symbol|
      fetch_stock(symbol, key)
    end

    render json: stocks
  end

  # GET /stocks/:id
  def show
    symbol = params[:id].upcase
    key = ENV["POLYGON_API_KEY"] || "0Q7EjcdhNI7i3bPbJ5Vg5usCKhocBNFV"

    if USE_MOCK
      render json: { symbol: symbol, price: rand(100..500) + rand.round(2), mock: true } and return
    end

    stock = fetch_stock(symbol, key)

    if stock[:price].present?
      render json: stock
    else
      render json: { error: "Stock not found" }, status: 404
    end
  end

  # GET /stocks/:id/candles
  def candles
    symbol = params[:id].upcase
    key = ENV["POLYGON_API_KEY"]

    # Example: last 30 days, 1-day candles
    url = URI("https://api.polygon.io/v2/aggs/ticker/#{symbol}/range/1/day/2024-07-01/2024-08-01?apiKey=#{key}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)
      render json: parsed["results"] || []
    else
      render json: { error: "Failed to fetch candles" }, status: 502
    end
  end

  private

  def fetch_stock(symbol, key)
    url = URI("#{BASE_URL}/#{symbol}?apiKey=#{key}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)
      data = parsed["ticker"]

      if data
        {
          symbol: data["ticker"],
          price: data.dig("lastTrade", "p") || data.dig("day", "c"),
          change: data["todaysChange"],
          change_percent: data["todaysChangePerc"]
        }
      else
        { symbol: symbol, price: nil }
      end
    else
      { symbol: symbol, price: nil }
    end
  end

  def make_request(url, limit = 5)
    raise "Too many HTTP redirects" if limit == 0

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    Rails.logger.info "🔎 Polygon Request URL: #{url}"
    response = http.request(request)

    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = URI(response["location"])
      Rails.logger.warn "🔀 Redirected to #{location}"
      make_request(location, limit - 1)
    else
      Rails.logger.error "❌ HTTP Error: #{response.code} #{response.message}"
      nil
    end
  end
end
