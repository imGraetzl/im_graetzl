class Notifications::ToolRentalCanceled < Notifications::PlatformNotification

  def self.description
    'Toolteiler Anfrage wurde zurückgezogen'
  end

  def tool_rental
    subject
  end

end
