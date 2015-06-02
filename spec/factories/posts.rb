FactoryGirl.define do
  factory :post do
    content { Faker::Lorem.paragraph }
    graetzl
    user
  end
end
