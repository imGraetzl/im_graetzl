class Notifications::LocationApproved < Notification

  TRIGGER_KEY = 'location.approve'
  BITMASK = 1024

  def self.receivers(activity)
    activity.trackable.users
  end
end
