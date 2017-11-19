class Notifications::NewRoomDemand < Notification
  TRIGGER_KEY = 'room_demand.create'
  BITMASK = 2**13

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_ids)
  end

  def self.description
    'Eine neue Raumsuche wurde im Grätzl veröffentlicht'
  end

  def self.notify_owner?
    true
  end

  def mail_vars
    {
      type: type.demodulize.underscore,
      post_title: activity.trackable.title,
      post_content: activity.trackable.content.truncate(255, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::AvatarService.new(activity.trackable.author).call,
      post_url: graetzl_user_post_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS)
    }
  end

  def mail_subject
    "Neue Raumsuche im deine Grätzl"
  end
end
