class Notifications::RoomRentalRejected < Notification

  def self.description
    'Raumteiler Anfrage wurde abgelehnt'
  end

  def room_rental
    subject
  end

end
