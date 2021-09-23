class Notifications::CommentOnDiscussionPost < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.bitmask = 2**21

  def self.description
    "Meine erstellten Inhalte wurden kommentiert"
  end

  def mail_subject
    "#{comment.user.username} hat deinen Beitrag kommentiert."
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
