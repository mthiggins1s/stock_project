class PortfolioStock < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  validates :shares, numericality: { greater_than: 0 }
  validates :avg_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
