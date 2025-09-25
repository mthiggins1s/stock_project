class AddSharesAndAvgCostToPortfolioStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolio_stocks, :shares, :integer
    add_column :portfolio_stocks, :avg_cost, :decimal
  end
end
