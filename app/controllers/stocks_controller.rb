require "net/http"
require "uri"
require "json"

class StocksController < ApplicationController
  # ✅ Updated base URL (RapidAPI redirect target)
  YAHOO_BASE = "https://api2.apidatacenter.com/api/v1"

  def index
    request.format = :json
    symbols = "AAPL,TSLA,MSFT,AMZN,GOOG"

    url = URI("#{YAHOO_BASE}/markets/quote?symbols=#{symbols}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)
      data = parsed["body"] || []

      stocks = data.map do |s|
        {
          symbol: s["symbol"],
          name: s["shortName"] || s["longName"],
          price: s["regularMarketPrice"]
        }
      end

      if params[:search].present?
        term = params[:search].downcase
        stocks = stocks.select do |s|
          s[:symbol].to_s.downcase.include?(term) ||
          s[:name].to_s.downcase.include?(term)
        end
      end

      render json: stocks.take(50)
    else
      render json: { error: "Failed to fetch stock list" }, status: 502
    end
  end

  def quote
    symbol = params[:id] || params[:symbol]
    url = URI("#{YAHOO_BASE}/markets/quote?symbols=#{symbol}")
    response = make_request(url)

    if response
      parsed = JSON.parse(response)
      stock = parsed["body"]&.first

      if stock
        render json: {
          symbol: stock["symbol"],
          name: stock["shortName"] || stock["longName"],
          price: stock["regularMarketPrice"]
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
    request["X-RapidAPI-Key"]  = ENV["YAHOO_API_KEY"]
    request["X-RapidAPI-Host"] = "api2.apidatacenter.com"   # ✅ direct host

    Rails.logger.info "🔎 Yahoo Request URL: #{url}"
    Rails.logger.info "🔎 Yahoo Request Headers: #{request.to_hash}"

    response = http.request(request)

    Rails.logger.info "🔎 Yahoo Response Code: #{response.code}"
    Rails.logger.info "🔎 Yahoo Response Body: #{response.body[0..200]}..." # preview

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
