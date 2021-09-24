class Notifications::MeetingUpdated < Notification
  DEFAULT_INTERVAL = :daily
  self.class_bitmask = 2**3

  def self.description
    'Änderungen eines Treffens an dem ich teilnehme'
  end

  def mail_subject
    'Es gibt Änderungen bei einem Treffen an dem du teilnimmst'
  end

  def meeting
    subject
  end

end
