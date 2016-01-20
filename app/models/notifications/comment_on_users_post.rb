class Notifications::CommentOnUsersPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 16

  def self.receivers(activity)
    User.where(id: activity.trackable.author_id)
  end

  def self.condition(activity)
    activity.trackable.author_type == 'User' && activity.trackable.author.present? && activity.trackable.author_id != activity.owner_id
  end

  def mail_vars
    {
      "post_title": activity.trackable.content.truncate(50, separator: ' '),
      "post_url": graetzl_post_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      "comment_url": graetzl_post_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      "comment_content": activity.recipient.content.truncate(300, separator: ' '),
      "owner_name": activity.owner.username,
      "owner_url": user_url(activity.owner, DEFAULT_URL_OPTIONS),
      "owner_avatar_url": ApplicationController.helpers.attachment_url(activity.owner, :avatar, :fill, 40, 40, fallback: "avatar/user/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
    }
  end

  def mail_subject
    "Neuer Kommentar auf deinen Beitrag"
  end
end
