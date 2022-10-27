class Notifications::ToolRentalApproved < Notifications::PlatformNotification

  def self.description
    'Deine Geräteteiler Anfrage wurde bestätigt'
  end

  def tool_rental
    subject
  end

end
