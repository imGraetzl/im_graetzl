class Notifications::CommentInMeeting < Notification
  DEFAULT_INTERVAL = :daily
  self.class_bitmask = 2**20

  def self.description
    "Ein Treffen an dem ich teilnehme wurde kommentiert"
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "#{child.user.username} hat ein Treffen kommentiert."
  end

  def headline
    'Neuer Kommentar bei einem Treffen'
  end

  def comment
    child
  end

  def content_title
    subject.to_s
  end

  def content_url_params
    [subject.graetzl, subject]
  end

  def target_url_params
    "comment_#{subject_type.underscore}_#{comment.id}"
  end

end
