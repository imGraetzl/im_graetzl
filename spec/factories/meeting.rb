require 'faker'

FactoryGirl.define do
  factory :meeting do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    address    

    factory :meeting_full do
      starts_at_date { Faker::Date.forward() }
      address
      graetzls { [build(:graetzl)] }
    end
  end
end