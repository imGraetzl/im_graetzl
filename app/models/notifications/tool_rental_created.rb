class Notifications::ToolRentalCreated < Notification

  def self.description
    'Neue Toolteiler Anfrage'
  end

  def tool_rental
    subject
  end

end
