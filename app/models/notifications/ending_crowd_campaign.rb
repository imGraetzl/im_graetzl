class Notifications::EndingCrowdCampaign < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**24

  def self.description
    'Eine Crowdfunding Kampagne endet bald'
  end

  def mail_subject
    "Eine Crowdfunding Kampagne #{I18n.t("region.#{region_id}.in_graetzl")} #{subject.graetzl.name} endet bald."
  end

  def crowd_campaign
    subject
  end

  def self.immediate_option_enabled?
    false
  end

end
