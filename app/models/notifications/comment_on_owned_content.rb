class Notifications::CommentOnOwnedContent < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**4

  def self.description
    'Meine erstellen Inhalte (Schaufenster, Treffen, Raumteiler, ...) wurden kommentiert'
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "Dein #{content_label} wurde kommentiert."
  end

  def headline
    "Neuer Kommentar bei deinem #{content_label}"
  end

  def comment
    child
  end

  def content_title
    case subject_type
    when 'LocationPost'
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
    when 'LocationPost'
      [subject.location.graetzl, subject.location]
    else
      subject
    end
  end

end
