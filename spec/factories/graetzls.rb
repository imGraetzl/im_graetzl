FactoryBot.define do
  factory :graetzl do
    sequence(:name) { |n| "Graetzl #{n}" }
    region_id { "wien" }
  end
end
