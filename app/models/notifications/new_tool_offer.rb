class Notifications::NewToolOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**19

  def self.description
    'Ein neuer Toolteiler wurde erstellt'
  end

  def mail_subject
    "Neuer Toolteiler #{self.region.id == 'wien' ? 'im Grätzl' : 'in der Gemeinde'} #{subject.graetzl.name}"
  end

  def tool_offer
    subject
  end

end
