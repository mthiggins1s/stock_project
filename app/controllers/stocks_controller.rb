class StocksController < ApplicationController
  def index
    request.format = :json
    url = URI("https://finnhub.io/api/v1/stock/symbol?exchange=US&token=#{ENV['FINNHUB_API_KEY']}")
    response = Net::HTTP.get(url)
    stocks = JSON.parse(response)

    filtered = stocks.select do |s|
      !s["symbol"].include?(".") &&
      !s["symbol"].end_with?("W") &&
      !s["symbol"].end_with?("U") &&
      !s["symbol"].end_with?("R") &&
      s["type"] == "Common Stock"
    end

    if params[:search].present?
      term = params[:search].downcase
      filtered = filtered.select do |s|
        s["symbol"].downcase.include?(term) ||
        (s["description"] && s["description"].downcase.include?(term))
      end
    end

    render json: filtered.take(50)
  end

  def quote
    symbol = params[:symbol]
    url = URI("https://finnhub.io/api/v1/quote?symbol=#{symbol}&token=#{ENV['FINNHUB_API_KEY']}")
    response = Net::HTTP.get(url)
    render json: JSON.parse(response)
  end
end
