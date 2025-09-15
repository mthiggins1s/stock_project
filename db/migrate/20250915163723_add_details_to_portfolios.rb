class AddDetailsToPortfolios < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :shares, :integer, default: 0, null: false
    add_column :portfolios, :avg_cost, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
