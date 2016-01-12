class Notifications::NewWallComment < Notification

  TRIGGER_KEY = 'user.comment'
  BITMASK = 512

  def self.receivers(activity)
    User.where(id: activity.trackable.id)
  end

  def self.condition(activity)
    activity.owner.present? && activity.recipient.present?
  end
end
