require 'rails_helper'

RSpec.describe Location, type: :model do
  it "is valid with valid attributes" do
    location = build(:location)
    expect(location).to be_valid
  end

  it "is not valid without an address" do
    location = build(:location, address: nil)
    expect(location).not_to be_valid
  end

  it "belongs to a user" do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq :belongs_to
  end
end
