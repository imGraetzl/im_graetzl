class Notifications::NewLocationPost < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**1

  def self.description
    'Ein Schaufenster hat eine Neuigkeit erstellt'
  end

  def mail_subject
    "Schaufenster News #{self.region.id == 'wien' ? 'aus dem Grätzl' : 'aus der Gemeinde'} #{subject.graetzl.name}"
  end

  def location
    subject
  end

  def location_post
    child
  end

end
