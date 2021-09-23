class Notifications::ToolRentalReturnPending < Notification

  def self.description
    'Toolteiler Rückgabe Bestätigung'
  end

  def tool_rental
    subject
  end
end
