require "net/http"
require "uri"
require "json"

class StocksController < ApplicationController
  def index
    request.format = :json
    url = URI("https://finnhub.io/api/v1/stock/symbol?exchange=US&token=#{ENV['FINNHUB_API_KEY']}")
    response = Net::HTTP.get(url)

    begin
      stocks = JSON.parse(response)
    rescue JSON::ParserError
      return render json: { error: "Invalid response from Finnhub" }, status: 502
    end

    filtered = stocks.select do |s|
      sym  = s["symbol"].to_s
      type = s["type"].to_s

      sym.present? &&
      !sym.include?(".") &&
      !sym.end_with?("W", "U", "R") &&
      type == "Common Stock"
    end

    if params[:search].present?
      term = params[:search].downcase
      filtered = filtered.select do |s|
        s["symbol"].to_s.downcase.include?(term) ||
        s["description"].to_s.downcase.include?(term)
      end
    end

    render json: filtered.take(50)
  end

  def quote
    symbol = params[:symbol]
    url = URI("https://finnhub.io/api/v1/quote?symbol=#{symbol}&token=#{ENV['FINNHUB_API_KEY']}")
    response = Net::HTTP.get(url)

    begin
      render json: JSON.parse(response)
    rescue JSON::ParserError
      render json: { error: "Invalid quote response" }, status: 502
    end
  end
end
