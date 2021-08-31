class Notifications::CommentOnLocationPost < Notification
  TRIGGER_KEY = 'location_post.comment'
  DEFAULT_INTERVAL = :immediate
  DEFAULT_WEBSITE_NOTIFICATION = :on
  BITMASK = 2**4

  def self.receivers(activity)
    User.where(id: activity.trackable.location.user_id)
  end

  def self.condition(activity)
    activity.trackable.location.user != activity.owner
  end

  def self.description
    "Meine erstellten Inhalte wurden kommentiert"
  end

  def mail_template
    "commented"
  end

  def mail_subject
    "#{activity.owner.username} hat dein Schaufenster-Update kommentiert."
  end

  def headline
    'Neuer Kommentar bei deinem Schaufenster-Update'
  end

  def content_title
    location_post.title
  end

  def content_url_params
    [location.graetzl, location]
  end

  def comment_content_preview
    activity.recipient.content.truncate(300, separator: ' ')
  end

  def comment_url_params
    [location.graetzl, location]
  end

  private

  def location_post
    activity.trackable
  end

  def location
    location_post.location
  end
end
