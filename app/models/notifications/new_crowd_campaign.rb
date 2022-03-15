class Notifications::NewCrowdCampaign < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**24

  def self.description
    'Es gibt eine neue Crowdfunding Kampagne'
  end

  def mail_subject
    "Es gibt eine neue Crowdfunding Kampagne #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name}"
  end

  def crowd_campaign
    subject
  end

end
