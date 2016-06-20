FactoryGirl.define do
  factory :meeting do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    address
    graetzl

    trait :basic do
      state { Meeting.states[:basic] }
    end

    trait :cancelled do
      state { Meeting.states[:cancelled] }
    end

    trait :skip_validate do
      to_create {|instance| instance.save(validate: false) }
    end
  end
end
