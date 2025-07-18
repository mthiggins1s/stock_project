class RecentlyViewed < ApplicationRecord
  belongs_to :user
  belongs_to :stock
end
