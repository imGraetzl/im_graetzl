class Notifications::CommentOnFollowedContent < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**6

  def self.description
    'Inhalte (Schaufenster, Treffen, Raumteiler, ...) welche ich kommentiert habe wurden auch kommentiert'
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
    case subject_type
    when 'LocationPost', 'LocationMenu'
      subject.location.to_s
    else
      subject.to_s
    end
  end

  def content_label
    case subject_type
    when 'Meeting'
      'Treffen'
    when 'Location'
      'Schaufenster'
    when 'LocationPost'
      'Schaufenster Update'
    when 'LocationMenu'
      'Menüplan'
    when 'RoomOffer', 'RoomDemand'
      'Raumteiler'
    when 'ToolOffer', 'ToolDemand'
      'Toolteiler'
    when 'CoopDemand'
      'Coop & Share Angebot'
    end
  end

  def content_url_params
    case subject_type
    when 'Meeting', 'Location'
      [subject.graetzl, subject]
    when 'LocationPost', 'LocationMenu'
      [subject.location.graetzl, subject.location]
    else
      subject
    end
  end

end
