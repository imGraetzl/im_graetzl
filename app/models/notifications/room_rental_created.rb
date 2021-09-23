class Notifications::RoomRentalCreated < Notification

  def self.description
    'Neue Toolteiler Anfrage'
  end

  def room_rental
    subject
  end

end
