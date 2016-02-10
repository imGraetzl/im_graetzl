FactoryGirl.define do
  factory :zuckerl do
    location
    title { Faker::Company.catch_phrase }
    description { Faker::Lorem.paragraph }
  end
end
