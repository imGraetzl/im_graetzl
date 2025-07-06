# app/jobs/crowd_pledge_charge_job.rb
class CrowdPledgeChargeJob < ApplicationJob
  queue_as :crowd_pledge_charge

  def perform(pledge_id)
    pledge = CrowdPledge.find(pledge_id)
    CrowdPledgeService.new.charge(pledge)
  end
end
