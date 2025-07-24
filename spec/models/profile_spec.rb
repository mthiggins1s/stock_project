require 'rails_helper'

RSpec.describe Profile, type: :model do
  it "is valid with valid attributes" do
    profile = build(:profile)
    expect(profile).to be_valid
  end

  it "is valid without a bio" do
    profile = build(:profile, bio: nil)
    expect(profile).to be_valid
  end

  it "belongs to a user" do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq :belongs_to
  end
end
