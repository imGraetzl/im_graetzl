class Notifications::NewRoomOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.bitmask = 2**12

  def self.description
    'Ein neues Raumangebot wurde im Grätzl erstellt'
  end

  def mail_subject
    "Neuer Raumteiler im Grätzl #{subject.graetzl.name}"
  end

  def room_offer
    subject
  end

end
