class CrowdCampaignService

  def start(campaign)
    campaign.update(status: :funding)
    ActionProcessor.track(campaign, :create)
    CrowdCampaignMailer.funding_started(campaign).deliver_later
  end

  def complete(campaign)
    campaign.update(status: :completed)

    if campaign.successful?
      campaign.crowd_pledges.find_each do |pledge|
        CrowdPledgeService.new.delay.charge(pledge)
        CrowdCampaignMailer.crowd_pledge_completed_successful(pledge).deliver_later
      end
      CrowdCampaignMailer.completed_successful(campaign).deliver_later
    else
      CrowdCampaignMailer.completed_unsuccessful(campaign).deliver_later
    end
  end

end
