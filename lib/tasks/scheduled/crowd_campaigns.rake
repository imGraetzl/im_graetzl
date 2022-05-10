namespace :scheduled do

  desc 'Daily update to Campaigns'
  task crowd_campaigns_upkeep: :environment do
    # Start scheduled campaigns
    campaign_start = Date.tomorrow.in_time_zone("Vienna").beginning_of_day.utc

    CrowdCampaign.approved.where(startdate: Date.tomorrow).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_start).start(campaign)
    end

    # Send emails after 7 days
    CrowdCampaign.funding.where(startdate: 7.days.ago).find_each do |campaign|
      CrowdCampaignMailer.keep_up(campaign).deliver_later
    end

    # Close expired
    campaign_end = Date.today.in_time_zone("Vienna").end_of_day.utc

    CrowdCampaign.funding.where(startdate: Date.today).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_end).complete(campaign)
    end
  end

end
