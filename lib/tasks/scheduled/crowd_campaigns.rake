namespace :scheduled do

  desc 'Daily update to Campaigns'
  task crowd_campaigns_upkeep: :environment do
    # Start scheduled campaigns
    campaign_start = Date.tomorrow.in_time_zone("Vienna").beginning_of_day.utc

    CrowdCampaign.approved.where(startdate: Date.tomorrow).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_start).start(campaign)
    end

    # Send email to funding campaign after 7 days
    CrowdCampaign.funding.where(startdate: 7.days.ago).find_each do |campaign|
      CrowdCampaignMailer.keep_up(campaign).deliver_later
    end

    # Send email to draft campaign after 30 days
    CrowdCampaign.draft.where(startdate: 30.days.ago).find_each do |campaign|
      CrowdCampaignMailer.draft(campaign).deliver_later
    end

    # Close expired
    campaign_end = Date.today.in_time_zone("Vienna").end_of_day.utc

    CrowdCampaign.funding.where(enddate: Date.today).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_end).complete(campaign)
    end

    # Send Reminder email to failed Pledges after 7 Days
    CrowdCampaign.completed.where(enddate: 7.days.ago).find_each do |campaign|
      campaign.crowd_pledges.failed.find_each do |pledge|
        CrowdCampaignMailer.crowd_pledge_failed_reminder(pledge).deliver_later
      end
    end

  end

end
