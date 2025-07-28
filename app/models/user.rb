class User < ApplicationRecord
  has_secure_password
  # Associations
  has_one :location, dependent: :destroy
  has_one :profile, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validate :validate_username
  validates :email, presence: true, uniqueness: true, length: { minimum: 5, maximum: 255 }, format: {
    with: URI::MailTo::EMAIL_REGEXP
  }
  validates :first_name, presence: true
  validates :last_name, presence: true

  after_create :create_profile

  private

  def validate_username
    unless username =~ /\A[a-zA-Z0-9_]+\Z/
      errors.add(:username, "can only contain letters, numbers, and underscores, and must have one letter or number")
    end
  end
end
