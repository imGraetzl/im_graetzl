require 'faker'

FactoryGirl.define do
  factory :meeting do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    address
    graetzl
  end
end