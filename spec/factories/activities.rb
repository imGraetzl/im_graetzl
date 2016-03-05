FactoryGirl.define do
  factory :activity do
    key 'meeting.create'
    association :trackable, factory: :meeting
    association :owner, factory: :user
  end
end
