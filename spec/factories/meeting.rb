FactoryGirl.define do
  factory :meeting do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    address
    graetzl

    factory :meeting_skip_validate do
      to_create {|instance| instance.save(validate: false) }
    end
  end
end
