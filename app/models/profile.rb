class Profile < ApplicationRecord
  belongs_to :user

  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :avatar_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
end
