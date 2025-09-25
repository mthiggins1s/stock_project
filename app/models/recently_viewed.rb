class RecentlyViewed < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :viewed_price, numericality: true, allow_nil: true
end
