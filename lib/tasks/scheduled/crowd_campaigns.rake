namespace :scheduled do

  desc 'Daily update to Campaigns'
  task crowd_campaigns_upkeep: :environment do
    # Start scheduled campaigns
    CrowdCampaign.approved.where("startdate = ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.start(campaign)
    end

    # Send emails after 7 days
    CrowdCampaign.funding.where(startdate: 7.days.ago).find_each do |campaign|
      CrowdCampaignMailer.keep_up(campaign).deliver_later
    end

    # Close expired
    CrowdCampaign.funding.where("enddate < ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.complete(campaign)
    end
  end

end
