FactoryGirl.define do
  factory :zuckerl do
    location
    title { Faker::Lorem.characters(80) }
    description { Faker::Lorem.paragraph }

    trait :live do
      aasm_state { 'live' }
    end

    trait :cancelled do
      aasm_state { 'cancelled' }
    end
  end
end
