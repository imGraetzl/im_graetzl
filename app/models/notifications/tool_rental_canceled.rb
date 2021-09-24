class Notifications::ToolRentalCanceled < Notification

  def self.description
    'Toolteiler Anfrage wurde zurückgezogen'
  end

  def tool_rental
    subject
  end

end
