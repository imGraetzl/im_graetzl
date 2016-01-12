class Notifications::AttendeeInUsersMeeting < Notification

  TRIGGER_KEY = 'meeting.go_to'
  BITMASK = 256
  # another_attendee: {
  #   triggered_by_activity_with_key: 'meeting.go_to',
  #   bitmask: 256,
  #   receivers: ->(activity) { User.where(id: activity.trackable.initiator.id) },
  #   condition: ->(activity) { activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id }
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
  #
  # def self.condition(activity)
  #   true
  # end
end
