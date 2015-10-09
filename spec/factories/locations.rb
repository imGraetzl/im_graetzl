FactoryGirl.define do
  factory :location do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
    description { Faker::Lorem.paragraph }
    contact
    graetzl
  end
end