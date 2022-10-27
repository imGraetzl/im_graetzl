class Notifications::ToolRentalCreated < Notifications::PlatformNotification

  def self.description
    'Neue Geräteteiler Anfrage'
  end

  def tool_rental
    subject
  end

end
