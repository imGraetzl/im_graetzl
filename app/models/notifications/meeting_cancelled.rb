class Notifications::MeetingCancelled < Notification
  # cancel_of_meeting: {
  #   triggered_by_activity_with_key: 'meeting.cancel',
  #   bitmask: 128,
  #   receivers: ->(activity) { activity.trackable.users }
  # },

  # TRIGGER_KEY = 'meeting.create'
  # BITMASK = 1 #TODO autosave right bitmask attribute for new records...
  #
  #
  #
  # def self.receivers(activity)
  #   User.where(graetzl_id: activity.trackable.graetzl_id)
  # end
  #
  # def self.triggered_by?(activity)
  #   activity.key == TRIGGER_KEY
  # end
  #
  # def self.condition(activity)
  #   true
  # end
end
