class Notifications::NewEnergyOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**26

  def self.description
    'Eine neue Energiegemeinschaft bzw. Suche wurde erstellt'
  end

  def mail_subject
    "Neue Energiegemeinschaft #{I18n.t("region.#{region_id}.in_graetzl")} #{self.user.graetzl.name}"
  end

  def energy_offer
    subject
  end

end
