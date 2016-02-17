class Notifications::CommentOnLocationsPost < Notification

  TRIGGER_KEY = 'post.comment'
  BITMASK = 32

  def self.receivers(activity)
    activity.trackable.author.users
  end

  def self.condition(activity)
    activity.trackable.author.present? && activity.trackable.author_type == "Location" && activity.trackable.author.users.exclude?(activity.owner)
  end

  def self.description
    "Eine Neuigkeit meiner Location wurden kommentiert"
  end

  def mail_vars
    {
      post_title: activity.trackable.title,
      post_url: graetzl_location_url(activity.trackable.author.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
      comment_url: graetzl_location_url(activity.trackable.author.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
      comment_content: activity.recipient.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.owner, :avatar, :fill, 40, 40, host: "http://#{DEFAULT_URL_OPTIONS[:host]}") || ApplicationController.helpers.image_url('avatar/user/40x40.png', host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
    }
  end

  def mail_subject
    'Neuer Kommentar auf deinen Beitrag'
  end
end
