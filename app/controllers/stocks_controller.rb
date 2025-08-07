class StocksController < ApplicationController
  # No authentication required here (public endpoint)

  def index
    # If a search query is present, filter stocks by symbol or name
    if params[:search]
      stocks = Stock.where("symbol LIKE ? OR name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      # Otherwise, return up to 4000 stocks
      stocks = Stock.all.limit(4000)
    end
    # Render stocks as JSON for the frontend
    render json: stocks
  end
end
