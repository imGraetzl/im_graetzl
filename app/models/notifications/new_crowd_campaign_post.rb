class Notifications::NewCrowdCampaignPost < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**25

  def self.description
    'Neuigkeit einer Crowdfunding Kampagne'
  end

  def mail_subject
    "Crowdfunding Update #{self.region.id == 'wien' ? 'aus dem Grätzl' : 'aus der Gemeinde'} #{subject.graetzl.name}"
  end

  def crowd_campaign
    subject
  end

  def crowd_campaign_post
    child
  end

end
