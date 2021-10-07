class Notifications::ToolRentalReturnPending < Notifications::PlatformNotification

  def self.description
    'Toolteiler Rückgabe Bestätigung'
  end

  def tool_rental
    subject
  end
end
