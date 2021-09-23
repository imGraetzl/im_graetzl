class Notifications::CommentOnFollowedContent < Notification
  DEFAULT_INTERVAL = :weekly
  self.bitmask = 2**6

  def self.description
    'Ein Raumteiler, Toolteiler bzw. Treffen welches ich kommentiert habe wurde auch kommentiert'
  end

  def mail_template
    "follow_commented"
  end

  def mail_subject
    "#{comment.user.username} hat einen #{content_label} ebenfalls kommentiert."
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
    when 'Location'
      'Schaufenster-Update'
    when 'RoomOffer', 'RoomDemand'
      'Raumteiler'
    when 'Toolteiler'
      'Toolteiler'
    end
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
