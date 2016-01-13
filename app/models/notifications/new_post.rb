class Notifications::NewPost < Notification

  TRIGGER_KEY = 'post.create'
  BITMASK = 2

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end
end
