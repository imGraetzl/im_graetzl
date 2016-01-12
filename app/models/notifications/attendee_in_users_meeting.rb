class Notifications::AttendeeInUsersMeeting < Notification

  TRIGGER_KEY = 'meeting.go_to'
  BITMASK = 256
  
  def self.receivers(activity)
    User.where(id: activity.trackable.initiator.id)
  end

  def self.condition(activity)
    activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id
  end
end
