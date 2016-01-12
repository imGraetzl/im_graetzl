class Notifications::CommentOnLocationsPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 16
  
  def self.receivers(activity)
    activity.trackable.author.users
  end

  def self.condition(activity)
    activity.trackable.author.present? && activity.trackable.author_type == "Location" && activity.trackable.author.users.exclude?(activity.owner)
  end
end
