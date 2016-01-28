class Notifications::NewLocationPost < Notification

  TRIGGER_KEY = 'post.create'
  BITMASK = 2

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def self.condition(activity)
    activity.trackable.author.is_a?(Location)
  end

  def mail_vars
    {
      post_content: activity.trackable.content.truncate(300, separator: ' '),
      owner_name: activity.trackable.author.name,
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.trackable.author, :avatar, :fill, 40, 40, fallback: "avatar/location/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
      owner_url: graetzl_location_url(activity.trackable.author.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
      post_title: activity.trackable.title,
      post_url: graetzl_location_url(activity.trackable.graetzl, activity.trackable.author, DEFAULT_URL_OPTIONS),
    }
  end

  def mail_subject
    "Neuer Beitrag im Grätzl #{activity.trackable.graetzl.name}"
  end
end
