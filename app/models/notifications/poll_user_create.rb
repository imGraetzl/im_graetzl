class Notifications::PollUserCreate < Notifications::PlatformNotification

  def self.description
    'Neuer Umfage Teilnehmer'
  end

  def poll
    subject
  end

  def poll_user
    child
  end

end
