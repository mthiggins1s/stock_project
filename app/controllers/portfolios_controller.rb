class PortfoliosController < ApplicationController
  before_action :authenticate_request

  # GET /portfolios
  def index
    holdings = @current_user.portfolio_stocks.includes(:stock).map do |ps|
      {
        id: ps.id,
        symbol: ps.stock.symbol,
        name: ps.stock.name,
        shares: ps.shares,
        avg_cost: ps.avg_cost,
        current_price: ps.stock.current_price,
        gain_loss: ps.shares * (ps.stock.current_price.to_f - ps.avg_cost.to_f)
      }
    end

    render json: holdings
  end

  # POST /portfolios
  def create
    stock = Stock.find_or_create_by(symbol: params[:symbol]) do |s|
      s.name = params[:name]
      s.current_price = params[:current_price]
    end

    portfolio_stock = @current_user.portfolio_stocks.find_or_initialize_by(stock: stock)
    portfolio_stock.shares ||= 0
    portfolio_stock.avg_cost ||= params[:avg_cost]
    portfolio_stock.shares += params[:shares].to_i
    portfolio_stock.save!

    render json: {
      id: portfolio_stock.id,
      symbol: stock.symbol,
      name: stock.name,
      shares: portfolio_stock.shares,
      avg_cost: portfolio_stock.avg_cost,
      current_price: stock.current_price
    }, status: :created
  end

  # DELETE /portfolios/:id
  def destroy
    ps = @current_user.portfolio_stocks.find_by(id: params[:id])
    if ps
      ps.destroy
      head :no_content
    else
      render json: { error: "Stock not found in portfolio" }, status: :not_found
    end
  end
end
