class Notifications::CommentInMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 64
  # comment_in_meeting: {
  #   triggered_by_activity_with_key: 'meeting.comment',
  #   bitmask: 64,
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
  #
  # def self.condition(activity)
  #   true
  # end
end
