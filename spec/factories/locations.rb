FactoryGirl.define do
  factory :location do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
    description { Faker::Lorem.paragraph }
    contact
    graetzl
    category

    factory :approved_location do
      state Location.states[:approved]
    end
  end
end
