class CrowdCampaignMailerPreview < ActionMailer::Preview

  def draft
    CrowdCampaignMailer.draft(CrowdCampaign.last)
  end

  def pending
    CrowdCampaignMailer.pending(CrowdCampaign.last)
  end

  def re_draft
    CrowdCampaignMailer.re_draft(CrowdCampaign.last)
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

  def boost_authorized
    CrowdCampaignMailer.boost_authorized(CrowdBoostPledge.last.crowd_campaign, CrowdBoostPledge.last)
  end

  def boost_waitlisted
    CrowdCampaignMailer.boost_waitlisted(CrowdBoostPledge.last.crowd_campaign)
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
    CrowdCampaignMailer.crowd_pledge_authorized(CrowdPledge.charges.last)
  end

  def crowd_pledge_debited
    CrowdCampaignMailer.crowd_pledge_debited(CrowdPledge.charges.order(:created_at).last)
  end

  def crowd_pledge_failed
    CrowdCampaignMailer.crowd_pledge_failed(CrowdPledge.charges.order(:created_at).last)
  end

  def crowd_pledge_failed_reminder
    CrowdCampaignMailer.crowd_pledge_failed_reminder(CrowdPledge.charges.order(:created_at).last)
  end

  def crowd_pledge_retried_debited
    CrowdCampaignMailer.crowd_pledge_retried_debited(CrowdPledge.charges.order(:created_at).last)
  end

  def crowd_pledge_goal_1_reached
    CrowdCampaignMailer.crowd_pledge_goal_1_reached(CrowdPledge.order(:created_at).last)
  end

  def crowd_pledge_newsletter
    region = Region.get('wien')
    CrowdCampaignMailer.crowd_pledge_newsletter(CrowdPledge.in(region).last, CrowdCampaign.funding.in(region).or(CrowdCampaign.platform))
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

  def ending_campaign_incomplete_reminder
    CrowdCampaignMailer.ending_campaign_incomplete_reminder(User.last, CrowdCampaign.first)
  end

end
