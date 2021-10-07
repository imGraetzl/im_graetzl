class Notifications::RoomRentalCanceled < Notifications::PlatformNotification

  def self.description
    'Raumteiler Anfrage wurde zurückgezogen'
  end

  def room_rental
    subject
  end

end
