class Notifications::NewMeeting < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**0

  def self.description
    'Ein neues Treffen wurde erstellt'
  end

  def mail_subject
    "Neues Treffen #{self.region.id == 'wien' ? 'im Grätzl' : 'in der Gemeinde'} #{subject.graetzl.name}"
  end

  def meeting
    subject
  end

end
