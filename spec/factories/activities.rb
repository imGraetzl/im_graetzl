FactoryGirl.define do
  factory :activity, :class => PublicActivity::Activity do
    key 'meeting.create'
  end
end
