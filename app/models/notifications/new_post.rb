class Notifications::NewPost < Notification

  TRIGGER_KEY = 'post.create'
  BITMASK = 2

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def mail_vars
    if activity.trackable.author.is_a?(User)
      {
        "post_content": activity.trackable.content.truncate(300, separator: ' '),
        "owner_name": activity.owner.username,
        "owner_url": user_url(activity.owner, DEFAULT_URL_OPTIONS),
        "owner_avatar_url": ApplicationController.helpers.attachment_url(activity.trackable.author, :avatar, :fill, 40, 40, fallback: "avatar/user/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
        "post_url": graetzl_post_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS)
      }
    else
      {
        "post_content": activity.trackable.content.truncate(300, separator: ' '),
        "owner_name": activity.trackable.author.name,
        "owner_avatar_url": ApplicationController.helpers.attachment_url(activity.trackable.author, :avatar, :fill, 40, 40, fallback: "avatar/location/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
        "owner_url": graetzl_location_url(activity.trackable.author.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
        "post_title": activity.trackable.title,
        "post_url": graetzl_location_url(activity.trackable.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
      }
    end
  end

  def mail_subject
    "Neuer Beitrag im Grätzl #{activity.trackable.graetzl.name}"
  end
end
