class Notifications::NewRoomDemand < Notification
  DEFAULT_INTERVAL = :weekly
  self.bitmask = 2**13

  def self.description
    'Eine neue Raumsuche wurde im Grätzl veröffentlicht'
  end

  def mail_subject
    "#{subject.user.username} sucht Räumlichkeiten"
  end

  def room_demand
    subject
  end
end
