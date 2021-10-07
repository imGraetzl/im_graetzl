class Notifications::RoomRentalCreated < Notifications::PlatformNotification

  def self.description
    'Neue Toolteiler Anfrage'
  end

  def room_rental
    subject
  end

end
