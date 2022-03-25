namespace :scheduled do

  desc 'Reminder for Tool expiring'
  task start_approved_crowd_campaigns: :environment do
    CrowdCampaign.approved.where("startdate >= ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.start(campaign)
    end
  end

  desc 'Reminder for Tool expiring'
  task close_expired_crowd_campaigns: :environment do
    CrowdCampaign.funding.where("enddate < ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.complete(campaign)
    end
  end

end
