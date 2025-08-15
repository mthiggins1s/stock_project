# app/models/location.rb
class Location < ApplicationRecord
  belongs_to :user
  # Remove `validates :address, presence: true`
  # Optional validations:
  validates :address, length: { maximum: 255 }, allow_blank: true
end
