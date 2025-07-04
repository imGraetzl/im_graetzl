# app/jobs/crowd_campaign_start_job.rb
class CrowdCampaignStartJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = CrowdCampaign.find(campaign_id)
    CrowdCampaignService.new.start(campaign)
  end
end
