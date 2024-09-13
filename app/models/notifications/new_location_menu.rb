class Notifications::NewLocationMenu < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**2

  def self.description
    'Ein Schaufenster hat einen Menüplan erstellt'
  end

  def mail_subject
    "Neuer Menüplan #{self.region.id == 'wien' ? 'aus dem Grätzl' : 'aus der Gemeinde'} #{subject.graetzl.name}"
  end

  def location
    subject
  end

  def location_menu
    child
  end

  def self.immediate_option_enabled?
    false
  end

end
