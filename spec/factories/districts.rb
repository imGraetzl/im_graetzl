FactoryGirl.define do
  factory :district do
    name { Faker::Address.city }
    zip { Faker::Address.zip }
    area 'POLYGON ((100.0 0.0, 101.0 0.0, 101.0 1.0, 100.0 1.0, 100.0 0.0))'
  end

end



