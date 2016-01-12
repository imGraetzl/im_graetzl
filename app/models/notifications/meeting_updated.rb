class Notifications::MeetingUpdated < Notification

  TRIGGER_KEY = 'meeting.update'
  BITMASK = 4
  # update_of_meeting: {
  #   triggered_by_activity_with_key: 'meeting.update',
  #   bitmask: 4,
  #   receivers: ->(activity) { activity.trackable.users }
  # },

  # TRIGGER_KEY = 'meeting.create'
  # BITMASK = 1 #TODO autosave right bitmask attribute for new records...
  #
  #
  #
  def self.receivers(activity)
    activity.trackable.users
  end
  #
  #
  # def self.condition(activity)
  #   true
  # end
end
