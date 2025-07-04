# app/jobs/crowd_campaign_complete_job.rb
class CrowdCampaignCompleteJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = CrowdCampaign.find(campaign_id)
    CrowdCampaignService.new.complete(campaign)
    Sentry.logger.info("[CrowdCampaignCompleteJob] Campaign %{campaign_id} completed", campaign_id: campaign.id)
  end
end
