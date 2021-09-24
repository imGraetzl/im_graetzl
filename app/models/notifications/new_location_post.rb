class Notifications::NewLocationPost < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**1

  def self.description
    'Ein Schaufenster aus deinem Grätzl hat eine Neuigkeit erstellt'
  end

  def mail_subject
    "Neuer Beitrag im Grätzl #{subject.graetzl.name}"
  end

  def location
    subject
  end

  def location_post
    child
  end

end
