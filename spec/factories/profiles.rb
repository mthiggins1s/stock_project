FactoryBot.define do
  factory :profile do
    bio { Faker::Lorem.paragraph }
    association :user
  end
end
