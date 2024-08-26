class Notifications::NewMeeting < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**0

  def self.description
    'Ein neues Treffen wurde erstellt'
  end

  def mail_subject
    if subject.entire_region?
      "Neues Treffen #{I18n.t("region.#{region_id}.in_graetzl")} #{self.user.graetzl.name}"
    else
      "Neues Treffen #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
    end
  end

  def meeting
    subject
  end

  def self.immediate_option_enabled?
    false
  end

end
