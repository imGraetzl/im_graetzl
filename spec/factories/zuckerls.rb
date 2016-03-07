FactoryGirl.define do
  factory :zuckerl do
    location
    title { Faker::Lorem.characters(80) }
    description { Faker::Lorem.paragraph }

    factory :live_zuckerl do
      aasm_state { 'live' }
    end
  end
end
