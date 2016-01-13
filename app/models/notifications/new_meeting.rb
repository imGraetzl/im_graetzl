class Notifications::NewMeeting < Notification

  TRIGGER_KEY = 'meeting.create'
  BITMASK = 1

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end
end
