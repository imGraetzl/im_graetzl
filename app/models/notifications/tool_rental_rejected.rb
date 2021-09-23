class Notifications::ToolRentalRejected < Notification

  def self.description
    'Toolteiler Anfrage wurde abgelehnt'
  end

  def tool_rental
    subject
  end

end
