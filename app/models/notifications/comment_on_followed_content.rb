class Notifications::CommentOnFollowedContent < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**6

  def self.description
    'Inhalte welche ich kommentiert habe wurden auch kommentiert'
  end

  def mail_template
    "follow_commented"
  end

  def mail_subject
    "Ein #{content_label} wurde ebenfalls kommentiert."
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
    when 'CoopDemand'
      'Coop & Share Angebot'
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
