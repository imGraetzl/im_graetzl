class Notifications::ToolRentalApproved < Notification

  def self.description
    'Deine Toolteiler Anfrage wurde bestätigt'
  end

  def tool_rental
    subject
  end

end
