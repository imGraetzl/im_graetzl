FactoryBot.define do
  factory :post do
    title { Faker::Hipster.sentence(3) }
    content { Faker::Hipster.paragraph }

    factory :location_post, class: 'LocationPost' do
      association :location, factory: :location
      graetzl
    end
  end
end
