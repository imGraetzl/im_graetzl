namespace :scheduled do

  desc 'Start Crowd Campaign Task'
  task start_approved_crowd_campaigns: :environment do
    CrowdCampaign.approved.where("startdate = ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.start(campaign)
    end
  end

  desc 'KeepUp Mailing Crowd Campaign Task'
  task keep_up_crowd_campaigns: :environment do    
    CrowdCampaign.funding.where(startdate: 7.days.ago).find_each do |campaign|
      CrowdCampaignMailer.keep_up(campaign).deliver_later
    end
  end

  desc 'Close Crowd Campaign Task'
  task close_expired_crowd_campaigns: :environment do
    CrowdCampaign.funding.where("enddate < ?", Date.today).find_each do |campaign|
      CrowdCampaignService.new.complete(campaign)
    end
  end

end
