require 'faker'

FactoryGirl.define do
  factory :user do |u|
    u.username { Faker::Internet.user_name }
    u.first_name { Faker::Name.first_name }
    u.last_name { Faker::Name.last_name }
    u.email { Faker::Internet.email }
    u.password { Faker::Internet.password(8) }
    u.password_confirmation { password }
    u.birthday { Faker::Date.birthday(min_age = 18, max_age = 100) }
    u.gender { 'female' }
    u.graetzl { build(:graetzl) }
    u.confirmed_at Date.today
  end
end