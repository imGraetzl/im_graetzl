class Notifications::CommentOnLocationsPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 16
  # user_comments_locations_post: {
  #   triggered_by_activity_with_key: 'post.comment',
  #   bitmask: 16,
  #   receivers: ->(activity) { activity.trackable.author.users },
  #   condition: ->(activity) { activity.trackable.author.present? && activity.trackable.author_type == "Location" && activity.trackable.author.users.exclude?(activity.owner) }
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
