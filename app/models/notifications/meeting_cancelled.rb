class Notifications::MeetingCancelled < Notification

  TRIGGER_KEY = 'meeting.cancel'
  BITMASK = 128
  
  def self.receivers(activity)
    activity.trackable.users
  end

  #TODO add condition (user must still exist...)
end
