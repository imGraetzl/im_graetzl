class Notifications::CommentOnUsersPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 16

  def self.receivers(activity)
    User.where(id: activity.trackable.author_id)
  end

  def self.condition(activity)
    activity.trackable.author_type == 'User' && activity.trackable.author.present? && activity.trackable.author_id != activity.owner_id
  end
end
