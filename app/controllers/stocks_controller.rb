require "net/http"
require "uri"
require "json"

class StocksController < ApplicationController
  BASE_URL = "https://www.alphavantage.co/query"
  USE_MOCK = false # 🔥 flip to true for fake prices during dev

  # GET /stocks
  def index
    request.format = :json
    symbols = %w[AAPL TSLA MSFT AMZN GOOG]

    if USE_MOCK
      stocks = symbols.map { |s| { symbol: s, price: rand(100..500) + rand.round(2), mock: true } }
      render json: stocks and return
    end

    key = Rails.application.credentials.dig(:alpha_vantage, :key)

    stocks = symbols.map do |symbol|
      url = URI("#{BASE_URL}?function=GLOBAL_QUOTE&symbol=#{symbol}&apikey=#{key}")
      response = make_request(url)

      if response
        parsed = JSON.parse(response)

        # ✅ Handle rate limit or invalid response
        if parsed["Note"] || parsed["Information"]
          Rails.logger.warn "⚠️ AlphaVantage issue for #{symbol}: #{parsed.inspect}"
          { symbol: symbol, price: rand(100..500) + rand.round(2), mock: true }
        else
          quote = parsed["Global Quote"]
          {
            symbol: symbol,
            price: quote ? quote["05. price"].to_f : nil
          }
        end
      else
        { symbol: symbol, price: nil }
      end
    end

    render json: stocks
  end

  # GET /stocks/:id
  def show
    symbol = params[:id]

    if USE_MOCK
      render json: { symbol: symbol, price: rand(100..500) + rand.round(2), mock: true } and return
    end

    key = Rails.application.credentials.dig(:alpha_vantage, :key)
    url = URI("#{BASE_URL}?function=GLOBAL_QUOTE&symbol=#{symbol}&apikey=#{key}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)

      # ✅ Handle rate limit or invalid response
      if parsed["Note"] || parsed["Information"]
        Rails.logger.warn "⚠️ AlphaVantage issue for #{symbol}: #{parsed.inspect}"
        render json: { symbol: symbol, price: rand(100..500) + rand.round(2), mock: true } and return
      end

      quote = parsed["Global Quote"]

      if quote && quote["05. price"]
        render json: {
          symbol: quote["01. symbol"],
          price: quote["05. price"].to_f
        }
      else
        render json: { error: "Stock not found" }, status: 404
      end
    else
      render json: { error: "Failed to fetch quote" }, status: 502
    end
  end

  private

  def make_request(url, limit = 5)
    raise "Too many HTTP redirects" if limit == 0

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    Rails.logger.info "🔎 Alpha Request URL: #{url}"
    response = http.request(request)

    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = URI(response["location"])
      Rails.logger.warn "🔀 Redirected to #{location}"
      make_request(location, limit - 1)
    else
      nil
    end
  end
end
