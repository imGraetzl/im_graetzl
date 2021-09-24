class Notifications::NewMeeting < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**0

  def self.description
    'Ein neues Treffen wurde im Grätzl erstellt'
  end

  def mail_subject
    "Neues Treffen im Grätzl #{self.user.graetzl.name}"
  end

  def meeting
    subject
  end

end
