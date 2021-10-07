class Notifications::ToolRentalCreated < Notifications::PlatformNotification

  def self.description
    'Neue Toolteiler Anfrage'
  end

  def tool_rental
    subject
  end

end
