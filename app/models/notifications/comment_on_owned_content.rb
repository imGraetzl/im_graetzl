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
    when 'LocationPost', 'LocationMenu'
      subject.location.to_s
    when 'CrowdCampaignPost'
      subject.crowd_campaign.to_s
    else
      subject.to_s
    end
  end

  def content_label
    case subject_type
    when 'Meeting'
      'Treffen'
    when 'Poll'
      'Umfrage'
    when 'Location'
      'Schaufenster'
    when 'LocationPost'
      'Schaufenster Update'
    when 'LocationMenu'
      'Menüplan'
    when 'RoomOffer', 'RoomDemand'
      'Raumteiler'
    when 'EnergyOffer', 'EnergyDemand'
      'Energieteiler'
    when 'ToolOffer', 'ToolDemand'
      'Geräteteiler'
    when 'CoopDemand'
      'Coop & Share Angebot'
    when 'CrowdCampaign'
      'Crowdfunding Projekt'
    when 'CrowdCampaignPost'
      'Crowdfunding Update'
    end
  end

  def content_url_params
    case subject_type
    when 'Meeting', 'Location'
      [subject.graetzl, subject]
    when 'LocationPost', 'LocationMenu'
      [subject.location.graetzl, subject.location]
    when 'CrowdCampaignPost'
      [subject.crowd_campaign]
    else
      subject
    end
  end

  def target_url_params
    "comment_#{subject_type.underscore}_#{comment.id}"
  end

end
