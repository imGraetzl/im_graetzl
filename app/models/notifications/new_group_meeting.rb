class Notifications::NewGroupMeeting < Notification
  DEFAULT_INTERVAL = :daily
  self.bitmask = 2**17

  def self.description
    'Eine neues Treffen wurde in der Gruppe erstellt.'
  end

  def mail_subject
    "Neues Gruppentreffen von #{subject.user.first_name} in der Gruppe #{group.title}"
  end

  def group
    meeting.group
  end

  def meeting
    subject
  end

end
