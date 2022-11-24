class Notifications::ToolRentalReturnPending < Notifications::PlatformNotification

  def self.description
    'Geräteteiler Rückgabe Bestätigung'
  end

  def tool_rental
    subject
  end
end
