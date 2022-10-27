class Notifications::ToolRentalCanceled < Notifications::PlatformNotification

  def self.description
    'Geräteteiler Anfrage wurde zurückgezogen'
  end

  def tool_rental
    subject
  end

end
