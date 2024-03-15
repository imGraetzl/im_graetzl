class CrowdCampaignMailerPreview < ActionMailer::Preview

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

  def invoice
    CrowdCampaignMailer.invoice(CrowdCampaign.completed.first)
  end

  def crowd_pledge_incomplete
    CrowdCampaignMailer.crowd_pledge_incomplete(CrowdPledge.incomplete.order(:created_at).last)
  end

  def crowd_pledge_authorized
    CrowdCampaignMailer.crowd_pledge_authorized(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_goal_1_reached
    CrowdCampaignMailer.crowd_pledge_goal_1_reached(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_debited
    CrowdCampaignMailer.crowd_pledge_debited(CrowdPledge.debited.order(:created_at).last)
  end

  def crowd_pledge_failed
    CrowdCampaignMailer.crowd_pledge_failed(CrowdPledge.failed.order(:created_at).last)
  end

  def crowd_pledge_failed_reminder
    CrowdCampaignMailer.crowd_pledge_failed_reminder(CrowdPledge.failed.order(:created_at).last)
  end

  def crowd_pledge_retried_debited
    CrowdCampaignMailer.crowd_pledge_retried_debited(CrowdPledge.processing.order(:created_at).last)
  end

  def crowd_pledge_newsletter
    region = Region.get('wien')
    CrowdCampaignMailer.crowd_pledge_newsletter(CrowdPledge.guest_newsletter_recipients.in(region).last, CrowdCampaign.guest_newsletter.in(region))
  end

  def crowd_donation_pledge_info
    CrowdCampaignMailer.crowd_donation_pledge_info(CrowdDonationPledge.order(:created_at).last)
  end

  def crowd_donation_pledge_success
    CrowdCampaignMailer.crowd_donation_pledge_success(CrowdDonationPledge.order(:created_at).last)
  end

  def message_to_user
    CrowdCampaignMailer.message_to_user(CrowdCampaign.first, CrowdPledge.last, "Hello", "Hello world")
  end

end
