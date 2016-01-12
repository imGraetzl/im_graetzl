class Notifications::CommentInMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 64

  def self.receivers(activity)
    activity.trackable.users
  end
end
