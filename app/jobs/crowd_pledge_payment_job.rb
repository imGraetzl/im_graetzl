class CrowdPledgePaymentJob < ApplicationJob
  queue_as :default

  def perform(crowd_pledge_id, payment_intent_data)
    crowd_pledge = CrowdPledge.find_by(id: crowd_pledge_id)
    unless crowd_pledge
      Rails.logger.warn "[stripe] ProcessCrowdPledgePaymentJob - CrowdPledge mit ID #{crowd_pledge_id} nicht gefunden – Job wird beendet"
      return
    end

    payment_intent = payment_intent_data.with_indifferent_access

    CrowdPledgeService.new.payment_succeeded(crowd_pledge, payment_intent)
  end
end
