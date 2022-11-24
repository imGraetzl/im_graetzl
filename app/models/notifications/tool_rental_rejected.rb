class Notifications::ToolRentalRejected < Notifications::PlatformNotification

  def self.description
    'Geräteteiler Anfrage wurde abgelehnt'
  end

  def tool_rental
    subject
  end

end
