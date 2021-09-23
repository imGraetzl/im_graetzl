class Notifications::ReplyOnFollowedComment < Notification
  DEFAULT_INTERVAL = :immediate
  self.bitmask = 2**22

  def self.description
    "Ein Beitrag den ich kommentiert habe wurde auch kommentiert"
  end

  def mail_template
    "follow_commented"
  end

  def mail_subject
    "#{comment.user.username} hat einen Beitrag ebenfalls kommentiert."
  end

  def headline
    'Neuer Kommentar bei einem Beitrag'
  end

  def comment
    child
  end

  def content_title
    subject.to_s
  end

  def content_url_params
    case subject_type
    when 'Meeting', 'Location'
      [subject.graetzl, subject]
    else
      subject
    end
  end

end
