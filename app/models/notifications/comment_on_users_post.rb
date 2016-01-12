class Notifications::CommentOnUsersPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 16
  # user_comments_users_post: {
  #   triggered_by_activity_with_key: 'post.comment',
  #   bitmask: 16,
  #   receivers: ->(activity) { User.where(id: activity.trackable.author_id) },
  #   condition: ->(activity) { activity.trackable.author_type == 'User' && activity.trackable.author.present? && activity.trackable.author_id != activity.owner_id}
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
