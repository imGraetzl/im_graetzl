class Notifications::AlsoCommentedUserPost < Notification
  TRIGGER_KEY = 'user_post.comment'
  DEFAULT_INTERVAL = :weekly
  BITMASK = 2**6

  def self.receivers(activity)
    User.where(id: activity.trackable.comments.includes(:user).pluck(:user_id) - [activity.owner_id])
  end

  def self.description
    'Es gibt neue Antworten auf Inhalte die ich auch kommentiert habe'
  end

  def mail_template
    "also_commented"
  end

  def mail_subject
    "#{activity.owner.username} hat einen Beitrag ebenfalls kommentiert."
  end

  def headline
    'Neuer Kommentar bei einem Beitrag'
  end

  def content_title
    user_post.title
  end

  def content_url_params
    [user_post.graetzl, user_post]
  end

  def comment_content_preview
    activity.recipient.content.truncate(300, separator: ' ')
  end

  def comment_url_params
    [user_post.graetzl, user_post]
  end

  private

  def user_post
    activity.trackable
  end

end
