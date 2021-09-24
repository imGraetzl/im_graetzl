class Notifications::MeetingAttended < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**9

  def self.description
    'Mein erstelltes Treffen hat einen neuen Teilnehmer'
  end

  def mail_subject
    "#{child.user.username} nimmt an deinem Treffen teil."
  end

  def meeting
    subject
  end

  def going_to
    child
  end

end
