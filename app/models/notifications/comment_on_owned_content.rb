class Notifications::CommentOnOwnedContent < Notification
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**4

  def self.description
    'Meine erstellen Inhalte wurden kommentiert'
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "#{comment.user.username} hat dein #{content_label} kommentiert."
  end

  def headline
    "Neuer Kommentar bei deinem #{content_label}"
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
