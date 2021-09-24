class Notifications::ReplyOnFollowedDiscussionPost < Notification
  DEFAULT_INTERVAL = :immediate
  self.class_bitmask = 2**22

  def self.description
    'Es gibt neue Antworten auf Inhalte die ich auch kommentiert habe'
  end

  def mail_subject
    "#{subject.user.username} hat einen Beitrag ebenfalls kommentiert."
  end

  def group
    subject.group
  end

  def discussion
    subject.discussion
  end

  def comment
    child
  end

end
