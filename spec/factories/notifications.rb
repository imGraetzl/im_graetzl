FactoryGirl.define do
  factory :notification do
    user
    seen false
    bitmask 1
    key { Notification::TYPES.keys.sample }
    type 'Notifications::NewMeeting'
  end
end
