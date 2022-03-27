class CrowdCampaignService

  def start(campaign)
    campaign.update(status: :funding)
    CrowdCampaignMailer.funding_started(crowd_campaign)
  end

  def complete(campaign)
    campaign.update(status: :completed)

    if campaign.successful?
      campaign.crowd_pledges.find_each do |pledge|
        CrowdPledgeService.new.delay.charge(pledge)
      end
      CrowdCampaignMailer.completed_successful(campaign).deliver_later
    else
      CrowdCampaignMailer.completed_unsuccessful(campaign).deliver_later
    end
  end

end