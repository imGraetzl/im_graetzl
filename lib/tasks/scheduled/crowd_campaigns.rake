namespace :scheduled do

  desc 'Start Crowd Campaign Task'
  task start_approved_crowd_campaigns: :environment do
    CrowdCampaign.approved.where("startdate = ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.start(campaign)
    end
  end

  desc 'Close Crowd Campaign Task'
  task close_expired_crowd_campaigns: :environment do
    CrowdCampaign.funding.where("enddate < ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.complete(campaign)
    end
  end

end
