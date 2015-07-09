require 'faker'

FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(8) }
    password_confirmation { password }
    birthday { Faker::Date.birthday(min_age = 18, max_age = 100) }
    gender 'female'
    graetzl
    confirmed_at Date.today
  end
end