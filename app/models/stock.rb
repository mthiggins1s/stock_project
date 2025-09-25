class Stock < ApplicationRecord
  has_many :portfolio_stocks, dependent: :destroy
  has_many :portfolios, through: :portfolio_stocks
  has_many :recently_vieweds, dependent: :destroy

  validates :symbol, presence: true, uniqueness: true
end
