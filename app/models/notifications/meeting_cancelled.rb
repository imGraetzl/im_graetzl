class Notifications::MeetingCancelled < Notification

  TRIGGER_KEY = 'meeting.cancel'
  BITMASK = 128
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
  def self.receivers(activity)
    activity.trackable.users
  end

  #TODO add condition (user must still exist...)
end
