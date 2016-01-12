class Notifications::NewWallComment < Notification

  TRIGGER_KEY = 'user.comment'
  BITMASK = 512
  # new_wall_comment: {
  #   triggered_by_activity_with_key: 'user.comment',
  #   bitmask: 512,
  #   receivers: ->(activity) { User.where(id: activity.trackable.id) },
  #   condition: ->(activity) { activity.owner.present? && activity.recipient.present? }
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
