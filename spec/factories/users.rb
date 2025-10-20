FactoryBot.define do
  factory :user do
    association :graetzl
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    first_name { "Test" }
    last_name { "User" }
    terms_and_conditions { true }
    business { false }
    password { "securePass123" }
    password_confirmation { password }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
