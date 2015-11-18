FactoryGirl.define do
  factory :post do
    content { Faker::Lorem.paragraph }
    graetzl
    association :author, factory: :user
  end
end
