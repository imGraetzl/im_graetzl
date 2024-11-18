class Notifications::CommentOnCrowdCampaign < Notification
  DEFAULT_INTERVAL = :daily
  DEFAULT_WEBSITE_NOTIFICATION = :on
  self.class_bitmask = 2**27

  def self.description
    'Meine Crowdfunding Kampagne wurde kommentiert'
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "Deine Crowdfunding Kampagne wurde kommentiert."
  end

  def headline
    "Neuer Kommentar bei deiner Crowdfunding Kampagne"
  end

  def comment
    child
  end

  def content_title
    subject.to_s
  end

  def content_url_params
    subject
  end

  def target_url_params
    "comment_#{subject_type.underscore}_#{comment.id}"
  end

end
