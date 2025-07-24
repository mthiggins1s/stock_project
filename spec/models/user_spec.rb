require 'rails_helper'

RSpec.describe User, type: :model do
  context "Validations tests" do
    it "is not valid without a first name" do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without a last name" do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without a username" do
      user = build(:user, username: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end

  context "Uniqueness tests" do
    it "is not valid without a unique username" do
      user1 = create(:user)
      user2 = build(:user, username: user1.username)

      expect(user2).not_to be_valid
      expect(user2.errors[:username]).to include("has already been taken")
    end

    it "is not valid without a unique email" do
      user1 = create(:user)
      user2 = build(:user, email: user1.email)

      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to include("has already been taken")
    end
  end

  context "destroy user and everything dependent on it" do
    let(:user) { create(:user) }
    let(:user_id) { user.id }

    before do
      user.destroy
    end

    it "deletes profile" do
      profile = Profile.find_by(user_id: user_id)
      expect(profile).to be_nil
    end

    it "deletes location" do
      expect(Location.find_by(user_id: user_id)).to be_nil
    end
  end

  # password
  it "is invalid when password is nil" do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  # hashes the password
  it "hashes the password" do
    user = create(:user, password: "password")
    expect(user.password_digest).not_to eq "password"
  end
end
