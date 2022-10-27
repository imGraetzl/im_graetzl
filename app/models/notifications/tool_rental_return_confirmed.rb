class Notifications::ToolRentalReturnConfirmed < Notifications::PlatformNotification

  def self.description
    'Geräteteiler Rückgabe bestätigt. Verleihvorgang bewerten.'
  end

  def tool_rental
    subject
  end

end
