require "net/http"
require "uri"
require "json"
require "ostruct"

class StocksController < ApplicationController
  SNAPSHOT_BASE   = "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers"
  REFERENCE_BASE  = "https://api.polygon.io/v3/reference/tickers"
  AGGREGATES_BASE = "https://api.polygon.io/v2/aggs/ticker"
  USE_MOCK        = false

  # GET /stocks
  def index
    request.format = :json
    symbols = %w[AAPL MSFT TSLA AMZN GOOG META NVDA NFLX AMD INTC ORCL IBM BA CAT KO PEP
                 JPM GS BAC WFC MS V MA UNH JNJ PFE MRK XOM CVX T VZ DIS NKE HD LOW COST
                 WMT TGT BKNG PYPL SQ SHOP ABNB UBER LYFT SNAP]
    key = ENV["POLYGON_API_KEY"]

    if USE_MOCK
      stocks = symbols.map do |s|
        OpenStruct.new(
          symbol: s,
          name: s,
          current_price: rand(100..500) + rand.round(2),
          change: rand(-5.0..5.0).round(2),
          change_percent: rand(-10.0..10.0).round(2),
          logo_url: nil
        )
      end
      render json: StockBlueprint.render(stocks) and return
    end

    stocks = symbols.map { |symbol| fetch_stock(symbol, key) }.compact
    render json: StockBlueprint.render(stocks)
  end

  # GET /stocks/:id
  def show
    symbol = params[:id].upcase
    key = ENV["POLYGON_API_KEY"]

    stock = fetch_stock(symbol, key)

    if stock && stock.current_price.present?
      render json: StockBlueprint.render(stock)
    else
      render json: { error: "Stock not found" }, status: 404
    end
  end

  # GET /stocks/:id/candles
  def candles
    symbol = params[:id].upcase
    key = ENV["POLYGON_API_KEY"]

    from       = params[:from]       || (Date.today - 30).to_s
    to         = params[:to]         || Date.today.to_s
    multiplier = params[:multiplier] || 1
    timespan   = params[:timespan]   || "day"

    url = URI("#{AGGREGATES_BASE}/#{symbol}/range/#{multiplier}/#{timespan}/#{from}/#{to}?apiKey=#{key}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)
      render json: parsed["results"] || []
    else
      render json: { error: "Failed to fetch candles" }, status: 502
    end
  end

  # GET /portfolio/candles
  def portfolio_candles
    key = ENV["POLYGON_API_KEY"]
    portfolio = JSON.parse(params[:symbols] || "[]")
    from       = params[:from]       || (Date.today - 30).to_s
    to         = params[:to]         || Date.today.to_s
    multiplier = params[:multiplier] || 1
    timespan   = params[:timespan]   || "day"

    all_candles = {}

    portfolio.each do |symbol|
      url = URI("#{AGGREGATES_BASE}/#{symbol}/range/#{multiplier}/#{timespan}/#{from}/#{to}?apiKey=#{key}")
      response = make_request(url)

      if response
        parsed = JSON.parse(response)
        all_candles[symbol] = parsed["results"] || []
      else
        all_candles[symbol] = []
      end
    end

    render json: all_candles
  end

  # GET /portfolio/summary
  def portfolio_summary
    key = ENV["POLYGON_API_KEY"]
    portfolio = JSON.parse(params[:symbols] || "[]")

    total_value = 0.0
    total_gains = 0.0
    total_losses = 0.0

    portfolio.each do |symbol|
      stock = fetch_stock(symbol, key)
      next unless stock && stock.current_price

      total_value += stock.current_price.to_f

      if stock.change.to_f > 0
        total_gains += stock.change.to_f
      else
        total_losses += stock.change.to_f
      end
    end

    render json: {
      total_value: total_value.round(2),
      gains: total_gains.round(2),
      losses: total_losses.round(2)
    }
  end

  private

  def fetch_stock(symbol, key)
    snapshot_url = URI("#{SNAPSHOT_BASE}/#{symbol}?apiKey=#{key}")
    ref_url = URI("#{REFERENCE_BASE}/#{symbol}?apiKey=#{key}")

    snapshot_res = make_request(snapshot_url)
    ref_res = make_request(ref_url)

    return nil unless snapshot_res

    snapshot_data = JSON.parse(snapshot_res)["ticker"]
    ref_data = ref_res ? JSON.parse(ref_res)["results"] : {}

    return nil unless snapshot_data

    OpenStruct.new(
      symbol: snapshot_data["ticker"],
      name: ref_data["name"] || snapshot_data["ticker"],
      current_price: snapshot_data.dig("lastTrade", "p") || snapshot_data.dig("day", "c"),
      change: snapshot_data["todaysChange"],
      change_percent: snapshot_data["todaysChangePerc"],
      logo_url: ref_data.dig("branding", "logo_url")
    )
  end

  def make_request(url, limit = 5)
    raise "Too many HTTP redirects" if limit == 0

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = URI(response["location"])
      make_request(location, limit - 1)
    when Net::HTTPNotFound
      # 🔇 Ignore 404s (missing tickers/logos) quietly
      nil
    else
      Rails.logger.warn "⚠️ Request failed for #{url} -> #{response.code} #{response.message}"
      nil
    end
  end
end
