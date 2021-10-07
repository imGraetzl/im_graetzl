class Notifications::RoomRentalApproved < Notifications::PlatformNotification

  def self.description
    'Deine Raumteiler Anfrage wurde bestätigt'
  end

  def room_rental
    subject
  end

end
