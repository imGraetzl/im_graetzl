FactoryGirl.define do
  factory :location do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
    description { Faker::Lorem.paragraph }
    address
    contact
    graetzl

    factory :location_pending do
      state Location.states[:pending]
    end

    factory :location_basic do
      state Location.states[:basic]
    end

    factory :location_managed do
      state Location.states[:managed]
    end
  end
end