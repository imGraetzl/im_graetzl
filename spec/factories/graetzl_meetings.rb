FactoryGirl.define do
  factory :graetzl_meeting do
    graetzl strategy: :create
    meeting strategy: :create
  end
end
