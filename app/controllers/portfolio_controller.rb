class PortfoliosController < ApplicationController
  before_action :authenticate_request  # require JWT here

  def index
    render json: @current_user.stocks
  end

  def create
    stock = Stock.find(params[:stock_id])
    @current_user.stocks << stock
    render json: { message: "Added #{stock.symbol} to portfolio" }, status: :created
  end

  def destroy
    stock = @current_user.stocks.find(params[:id])
    @current_user.stocks.delete(stock)
    head :no_content
  end
end
