class PortfoliosController < ApplicationController
  before_action :authenticate_request

  # GET /portfolios
  def index
    render json: StockBlueprint.render(@current_user.stocks)
  end

  # POST /portfolios
  def create
    stock = Stock.find_or_create_by(symbol: params[:symbol])
    unless @current_user.stocks.exists?(stock.id)
      @current_user.stocks << stock
    end
    render json: StockBlueprint.render(stock), status: :created
  end

  # DELETE /portfolios/:id
  def destroy
    stock = @current_user.stocks.find_by(id: params[:id]) || @current_user.stocks.find_by(symbol: params[:id])
    if stock
      @current_user.stocks.destroy(stock)
      head :no_content
    else
      render json: { error: "Stock not found in portfolio" }, status: :not_found
    end
  end
end
