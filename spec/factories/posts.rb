FactoryGirl.define do
  factory :post do
    title { Faker::Hipster.sentence(3) }
    content { Faker::Hipster.paragraph }
    graetzl
    association :author, factory: :user
  end
end
