class CrowdCampaignMailerPreview < ActionMailer::Preview

  def draft
    CrowdCampaignMailer.draft(CrowdCampaign.last)
  end

  def pending
    CrowdCampaignMailer.pending(CrowdCampaign.last)
  end

  def approved
    CrowdCampaignMailer.approved(CrowdCampaign.last)
  end

  def funding_started
    CrowdCampaignMailer.funding_started(CrowdCampaign.last)
  end

  def goal_1_reached
    CrowdCampaignMailer.goal_1_reached(CrowdCampaign.last)
  end

  def goal_2_reached
    CrowdCampaignMailer.goal_2_reached(CrowdCampaign.last)
  end

  def completed_successful
    CrowdCampaignMailer.completed_successful(CrowdCampaign.last)
  end

  def completed_unsuccessful
    CrowdCampaignMailer.completed_unsuccessful(CrowdCampaign.last)
  end

end
