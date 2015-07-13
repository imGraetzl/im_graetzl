FactoryGirl.define do
  factory :location do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
    description { Faker::Lorem.paragraph }
    address
    graetzl    
  end

end
