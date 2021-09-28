class Notifications::NewRoomOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**12

  def self.description
    'Ein neues Raumangebot wurde erstellt'
  end

  def mail_subject
    "Neuer Raumteiler #{self.region.id == 'wien' ? 'im Grätzl' : 'in der Gemeinde'} #{subject.graetzl.name}"
  end

  def room_offer
    subject
  end

end
