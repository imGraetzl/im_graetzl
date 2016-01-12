class Notifications::NewPost < Notification

  TRIGGER_KEY = 'post.create'
  BITMASK = 2

  # TRIGGER_KEY = 'meeting.create'
  # BITMASK = 1 #TODO autosave right bitmask attribute for new records...
  #
  # new_post_in_graetzl: {
  #   bitmask: 2,
  #   triggered_by_activity_with_key: 'post.create',
  #   receivers: ->(activity) { User.where(graetzl_id: activity.trackable.graetzl_id) }
  # },
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
