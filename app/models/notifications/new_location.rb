class Notifications::NewLocation < Notification
  TRIGGER_KEY = 'location.create'
  DEFAULT_INTERVAL = :weekly
  BITMASK = 2**5

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def self.description
    'Es gibt ein neues Schaufenster in deinem Grätzl'
  end

  def mail_subject
    'Es gibt ein neues Schaufenster in deinem Grätzl'
  end

  def location
    activity.trackable
  end

end
