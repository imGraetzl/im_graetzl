class Notifications::AlsoCommentedMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 32
  # another_user_comments_meeting: {
  #   triggered_by_activity_with_key: 'meeting.comment',
  #   bitmask: 32,
  #   receivers: ->(activity) { User.where(id: activity.trackable.comments.includes(:user).pluck(:user_id) - [activity.owner_id]) }
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
