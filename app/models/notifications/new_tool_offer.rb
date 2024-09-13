class Notifications::NewToolOffer < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**19

  def self.description
    'Ein neuer Geräteteiler / Gerätesuche wurde erstellt'
  end

  def mail_subject
    "Neuer Geräteteiler #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def tool_offer
    subject
  end

  def self.immediate_option_enabled?
    false
  end

end
