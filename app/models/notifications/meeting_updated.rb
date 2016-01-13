class Notifications::MeetingUpdated < Notification

  TRIGGER_KEY = 'meeting.update'
  BITMASK = 4

  def self.receivers(activity)
    activity.trackable.users
  end
end
