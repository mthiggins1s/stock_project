class PortfoliosController < ApplicationController
  before_action :authenticate_request

  # GET /portfolios
  def index
    portfolio = @current_user.portfolios.first_or_create!
    holdings = portfolio.portfolio_stocks.includes(:stock)

    render json: holdings.as_json(
      include: {
        stock: {
          only: [ :id, :symbol, :name, :current_price ]
        }
      },
      only: [ :id, :shares, :avg_cost ]
    )
  end

  # POST /portfolios
  def create
    portfolio = @current_user.portfolios.first_or_create!
    stock = Stock.find_or_create_by(symbol: params[:symbol]) do |s|
      s.name = params[:name]
      s.current_price = params[:current_price]
    end

    holding = portfolio.portfolio_stocks.find_or_initialize_by(stock: stock)
    holding.shares ||= 0
    holding.shares += params[:shares].to_i
    holding.avg_cost = params[:avg_cost] if params[:avg_cost]
    holding.save!

    render json: holding.as_json(
      include: {
        stock: {
          only: [ :id, :symbol, :name, :current_price ]
        }
      },
      only: [ :id, :shares, :avg_cost ]
    ), status: :created
  end

  # DELETE /portfolios/:id
  def destroy
    portfolio = @current_user.portfolios.first_or_create!
    holding = portfolio.portfolio_stocks.find_by(id: params[:id])

    if holding
      holding.destroy
      head :no_content
    else
      render json: { error: "Holding not found" }, status: :not_found
    end
  end
end
