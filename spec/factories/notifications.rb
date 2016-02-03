FactoryGirl.define do
  factory :notification do
    user
    seen false
    bitmask 1
    type 'Notifications::NewMeeting'

    factory :notification_new_meeting, class: 'Notifications::NewMeeting' do
    end

    factory :notification_also_commented_meeting, class: 'Notifications::NewMeeting' do
    end

    # factory :notification_new_meeting, class: 'Notifications::NewMeeting' do
    # end
    #
    # factory :notification_new_meeting, class: 'Notifications::NewMeeting' do
    # end
    #
    # factory :notification_new_meeting, class: 'Notifications::NewMeeting' do
    # end
  end
end
