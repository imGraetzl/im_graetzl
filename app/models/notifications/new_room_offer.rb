class Notifications::NewRoomOffer < Notification
  TRIGGER_KEY = 'room_offer.create'
  BITMASK = 2**12

  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  def self.description
    'Ein neues Raumangebot wurde im Grätzl erstellt'
  end

  def self.notify_owner?
    true
  end

  def mail_vars
    {
      room_name: activity.trackable.slogan,
      room_url: room_offer_url(activity.trackable, DEFAULT_URL_OPTIONS),
      room_type: activity.trackable.offer_type,
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::AvatarService.new(activity.owner).call,
    }
  end

  def mail_subject
    "Neuer Raumteiler im Grätzl #{activity.trackable.graetzl.name}"
  end
end
