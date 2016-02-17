FactoryGirl.define do
  factory :zuckerl do
    location
    title { Faker::Lorem.characters(80) }
    description { Faker::Lorem.paragraph }
  end
end
