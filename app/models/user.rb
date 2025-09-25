class User < ApplicationRecord
  has_secure_password

  has_one :profile, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :portfolio_stocks, through: :portfolios
  has_many :stocks, through: :portfolio_stocks
  has_many :recently_vieweds, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :public_id, presence: true, uniqueness: true

  before_validation :generate_public_id, on: :create
  after_create :create_profile

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end

  def create_profile
    Profile.create!(user: self)
  end
end
