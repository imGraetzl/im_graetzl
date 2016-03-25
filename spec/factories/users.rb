require 'faker'

FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(8) }
    graetzl
    confirmed_at Date.today
    enabled_website_notifications 0
    immediate_mail_notifications 0
    daily_mail_notifications 0
    weekly_mail_notifications 0

    trait :admin do
      role User.roles[:admin]
    end

    trait :guest do
      role User.roles[:guest]
    end
  end
end
