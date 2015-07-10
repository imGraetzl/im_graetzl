FactoryGirl.define do
  factory :notification do
    user
    seen false
    bitmask 1
  end
end
