# app/jobs/crowd_campaign_start_job.rb
class CrowdCampaignStartJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = CrowdCampaign.find(campaign_id)
    CrowdCampaignService.new.start(campaign)
    Sentry.logger.info("[CrowdCampaignStartJob] Campaign %{campaign_id} started", campaign_id: campaign.id)
  end
end
