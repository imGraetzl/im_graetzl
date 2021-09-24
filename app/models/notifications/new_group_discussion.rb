class Notifications::NewGroupDiscussion < Notification
  DEFAULT_INTERVAL = :daily
  self.class_bitmask = 2**15

  def self.description
    'Eine neue Diskussion wurde gestartet.'
  end

  def mail_subject
    "Neues Thema von #{discussion.user.first_name} in der Gruppe #{group.title}."
  end

  def discussion
    subject
  end

  def group
    discussion.group
  end

  def initial_post
    discussion.first_post
  end

end
