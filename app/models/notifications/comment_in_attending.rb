class Notifications::CommentInAttending < Notification
  DEFAULT_INTERVAL = :daily
  self.class_bitmask = 2**20

  def self.description
    "Ein Treffen an dem ich teilnehme wurde kommentiert"
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "Neuer Kommentar bei einem #{content_label} von #{child.user.username}."
  end

  def headline
    "Neuer Kommentar bei einem #{content_label}"
  end

  def comment
    child
  end

  def content_title
    subject.to_s
  end

  def content_label
    case subject_type
    when 'Meeting'
      'Treffen'
    when 'Poll'
      'Umfrage'
    end
  end

  def content_url_params
    case subject_type
    when 'Meeting'
      [subject.graetzl, subject]
    else
      subject
    end
  end

  def target_url_params
    "comment_#{subject_type.underscore}_#{comment.id}"
  end

end
