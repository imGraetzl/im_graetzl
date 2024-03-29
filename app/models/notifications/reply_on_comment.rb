class Notifications::ReplyOnComment < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**21

  def self.description
    "Ein von mir verfasster Beitrag wurde kommentiert"
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "#{comment.user.username} hat deinen Beitrag kommentiert."
  end

  def headline
    'Neuer Kommentar bei deinem Beitrag'
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

  def target_url_params
    "comment_comment_#{comment.id}"
  end

end
