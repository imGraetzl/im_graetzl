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

  def keep_up
    CrowdCampaignMailer.keep_up(CrowdCampaign.last)
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

  def crowd_pledge_authorized
    CrowdCampaignMailer.crowd_pledge_authorized(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_debited
    CrowdCampaignMailer.crowd_pledge_debited(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_failed
    CrowdCampaignMailer.crowd_pledge_failed(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_retried_debited
    CrowdCampaignMailer.crowd_pledge_retried_debited(CrowdPledge.order(:created_at).last)
  end

  def crowd_donation_pledge_info
    CrowdCampaignMailer.crowd_donation_pledge_info(CrowdDonationPledge.order(:created_at).last)
  end

end
