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
  # def self.receivers(activity)
  #   User.where(graetzl_id: activity.trackable.graetzl_id)
  # end
  #
  def self.triggered_by?(activity)
    activity.key == TRIGGER_KEY
  end
  #
  # def self.condition(activity)
  #   true
  # end
end
