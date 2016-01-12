class Notifications::AlsoCommentedMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 32

  def self.receivers(activity)
    User.where(id: activity.trackable.comments.includes(:user).pluck(:user_id) - [activity.owner_id])
  end
end
