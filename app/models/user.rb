class User < ApplicationRecord
  has_secure_password

  # Associations
  has_one :location, dependent: :destroy
  has_one :profile,  dependent: :destroy

  # Normalize inputs before we validate (trims & downcases)
  before_validation :normalize_identity_fields

  # Validations
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 }
  validate  :validate_username

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 5, maximum: 255 },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :first_name, presence: true
  validates :last_name,  presence: true

  # Ensure the required associations exist right after create
  after_create :ensure_profile_and_location

  private

  # Create the associated records if missing
  def ensure_profile_and_location
    create_profile!  unless profile
    create_location! unless location
  end

  # Trim whitespace and normalize case to prevent dupes like "Matt" vs "matt"
  def normalize_identity_fields
    self.username = username.to_s.strip.downcase.presence
    self.email    = email.to_s.strip.downcase.presence
  end

  def validate_username
    return if username.present? && username.match?(/\A[a-zA-Z0-9_]+\z/)
    errors.add(:username, "may only contain letters, numbers, and underscores")
  end
end
