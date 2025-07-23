class User < ApplicationRecord
  # prevents user creation with null input
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, uniqueness: true, length: { minimum: 5, maximum: 255 }, format: {
    with: URI::MailTo::EMAIL_REGEXP
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
end
