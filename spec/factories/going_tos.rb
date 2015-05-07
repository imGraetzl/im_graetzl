FactoryGirl.define do
  factory :going_to do
    user strategy: :create
    meeting strategy: :create
    role 1
  end
end
