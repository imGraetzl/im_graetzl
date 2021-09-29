class Notifications::NewRoomOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**12

  def self.description
    'Ein neues Raumangebot wurde erstellt'
  end

  def mail_subject
    "Neuer Raumteiler #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def room_offer
    subject
  end

end
