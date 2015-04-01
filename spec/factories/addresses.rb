require 'faker'

FactoryGirl.define do
  factory :address do |a|
    a.street_name { Faker::Address.street_name }
    a.street_number { Faker::Address.secondary_address }
    a.zip { Faker::Address.zip }
    a.city { Faker::Address.city }
    a.coordinates { "POINT(#{Faker::Address.longitude} #{Faker::Address.latitude})" }
  end
end