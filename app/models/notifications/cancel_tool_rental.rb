class Notifications::CancelToolRental < Notification
  TRIGGER_KEY = 'tool_rental.cancel'
  DEFAULT_INTERVAL = :immediate
  BITMASK = 2**4

  def self.receivers(activity)
    User.where(id: activity.trackable.tool_offer.user.id)
  end

  def self.description
    'Toolteiler Anfrage wurde zurückgezogen'
  end

  def tool_rental
    activity.trackable
  end
end
