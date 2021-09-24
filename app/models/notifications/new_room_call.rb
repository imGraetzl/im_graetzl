class Notifications::NewRoomCall < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**14

  def self.description
    'Eine gibt einen neuen Raumteiler Call'
  end

  def mail_subject
    "#{subject.user.username} hat einen neuen Call gestartet."
  end

  def room_call
    subject
  end

end
