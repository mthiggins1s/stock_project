class SimplifyPortfolios < ActiveRecord::Migration[7.1]
  def change
    # Drop the join table, we won’t need it anymore
    drop_table :portfolio_stocks, if_exists: true

    # Add stock_id directly to portfolios
    add_column :portfolios, :stock_id, :integer
    add_index :portfolios, :stock_id
    add_foreign_key :portfolios, :stocks
  end
end
