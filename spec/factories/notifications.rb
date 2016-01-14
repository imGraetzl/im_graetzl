FactoryGirl.define do
  factory :notification do
    user
    seen false
    bitmask 1
    type 'Notifications::NewMeeting'
  end
end
