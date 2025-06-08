class CrowdPledgePaymentJob < ApplicationJob
  queue_as :default

  retry_on Stripe::APIConnectionError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(crowd_pledge_id, payment_intent_id)
    crowd_pledge = CrowdPledge.find(crowd_pledge_id)

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] CrowdPledgePaymentJob - PaymentIntent #{payment_intent_id} konnte nicht geladen werden: #{e.message}"
      return
    end

    CrowdPledgeService.new.payment_succeeded(crowd_pledge, payment_intent)
  end
end
