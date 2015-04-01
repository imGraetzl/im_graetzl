require 'faker'

FactoryGirl.define do
  factory :address do |a|
    a.street_name { Faker::Address.street_name }
    a.street_number { Faker::Address.secondary_address }
    a.zip { Faker::Address.zip }
    a.city { Faker::Address.city }
    a.coordinates { "POINT(#{Faker::Address.longitude} #{Faker::Address.latitude})" }

    factory :seestadt do |a|
      a.street_name 'Seestadtstraße'
      a.city 'Wien'
      a.coordinates 'POINT (16.508413324531308 48.219917789263086)'
    end

  end

  factory :esterhazygasse, class: Address do |a|
    a.street_name 'Esterházygasse'
    a.street_number '5'
    a.zip '1060'
    a.city 'Wien'
    a.coordinates 'POINT (16.353172456228375 48.194235057984216)'
  end
end