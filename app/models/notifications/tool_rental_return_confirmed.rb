class Notifications::ToolRentalReturnConfirmed < Notification

  def self.description
    'Toolteiler Rückgabe bestätigt. Verleihvorgang bewerten.'
  end

  def tool_rental
    subject
  end

end
