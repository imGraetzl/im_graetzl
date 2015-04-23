require 'faker'

FactoryGirl.define do
  factory :meeting do |m|
    m.name { Faker::Lorem.sentence() }
    m.description { Faker::Lorem.paragraph }
    m.user_initialized { build(:user) }
    m.starts_at { Faker::Date.forward() }
    m.address { build(:address) }
    m.graetzls { [build(:graetzl)] }
  end
end