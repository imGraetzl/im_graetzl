FactoryGirl.define do
  factory :curator do
    graetzl
    user
    website { Faker::Internet.url }
    desciption { Faker::Hipster.sentence }
  end
end
