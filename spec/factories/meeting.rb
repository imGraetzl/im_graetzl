require 'faker'

FactoryGirl.define do
  factory :meeting do |m|
    m.name { Faker::Lorem.sentence }
    m.description { Faker::Lorem.paragraph }

    factory :meeting_full do |m|
      m.starts_at_date { Faker::Date.forward() }
      m.address { build(:address) }
      m.graetzls { [build(:graetzl)] }
    end
  end
end