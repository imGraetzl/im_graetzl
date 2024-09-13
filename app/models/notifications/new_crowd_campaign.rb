class Notifications::NewCrowdCampaign < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**24

  def self.description
    'Eine neue Crowdfunding Kampagne wurde gestartet'
  end

  def mail_subject
    "Es gibt eine neue Crowdfunding Kampagne #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def crowd_campaign
    subject
  end

  def self.immediate_option_enabled?
    false
  end

end
