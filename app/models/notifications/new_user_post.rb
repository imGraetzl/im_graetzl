class Notifications::NewUserPost < Notification

  TRIGGER_KEY = 'post.create'
  BITMASK = 4

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def self.condition(activity)
    activity.trackable.author.is_a?(User)
  end

  def self.description
    "Ein User hat einen neuen Beitrag im Grätzl erstellt"
  end

  def mail_vars
    {
      type: type.demodulize.underscore,
      post_content: activity.trackable.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.trackable.author, :avatar, :fill, 40, 40, fallback: "avatar/user/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
      post_url: graetzl_post_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS)
    }
  end

  def mail_subject
    "Neuer Beitrag im Grätzl #{activity.trackable.graetzl.name}"
  end
end
