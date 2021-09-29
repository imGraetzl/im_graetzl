class Notifications::NewMeeting < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**0

  def self.description
    'Ein neues Treffen wurde erstellt'
  end

  def mail_subject
    "Neues Treffen #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def meeting
    subject
  end

end
