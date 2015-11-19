FactoryGirl.define do
  factory :curator do
    graetzl
    user
    website { Faker::Internet.url }
    description { Faker::Lorem.sentence }
  end
end
