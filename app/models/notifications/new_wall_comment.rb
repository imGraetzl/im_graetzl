class Notifications::NewWallComment < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**10

  def self.description
    'Jemand hat auf meine Pinnwand geschrieben'
  end

  def mail_subject
    "#{comment.user.username} hat auf deine Pinnwand geschrieben."
  end

  def comment
    child
  end

end
