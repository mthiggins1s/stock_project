class StocksController < ApplicationController
  def index
    if params[:search]
      stocks = Stock.where("symbol LIKE ? OR name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      stocks = Stock.all.limit(4000)
    end
    render json: stocks
  end
end

# What is this doing?
# the 'index' action is what runs when someone visits /stocks (GET Request)
# the :search param will check if a search param was provided EXAMPLE would be /stocks?search=Apple
# Next, the Stock.where will basically check for the symbole or name of the stock that was searched, if it finds it, it will provided the outcome of the stock
# If nothing is typed, stocks = Stock.all.limit(50) provides the first fifty stocks automatically
# finally, it is then rendered in JSON
