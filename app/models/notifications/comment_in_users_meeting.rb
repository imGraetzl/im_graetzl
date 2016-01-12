class Notifications::CommentInUsersMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 8
  # user_comments_users_meeting: {
  #   triggered_by_activity_with_key: 'meeting.comment',
  #   bitmask: 8,
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
  def self.triggered_by?(activity)
    activity.key == TRIGGER_KEY
  end
  #
  # def self.condition(activity)
  #   true
  # end
end
