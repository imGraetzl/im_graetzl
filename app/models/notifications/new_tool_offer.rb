class Notifications::NewToolOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.bitmask = 2**19

  def self.description
    'Ein neuer Toolteiler wurde im Grätzl erstellt'
  end

  def mail_subject
    "Neuer Toolteiler im Grätzl #{subject.graetzl.name}"
  end

  def tool_offer
    subject
  end

end
