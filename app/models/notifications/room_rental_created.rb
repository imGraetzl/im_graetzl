class Notifications::RoomRentalCreated < Notifications::PlatformNotification

  def self.description
    'Neue Raumteiler Anfrage'
  end

  def room_rental
    subject
  end

end
