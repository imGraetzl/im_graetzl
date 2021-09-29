class Notifications::NewLocation < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**5

  def self.description
    'Es gibt ein neues Schaufenster'
  end

  def mail_subject
    "Es gibt ein neues Schaufenster #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def location
    subject
  end

end
