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

    begin
      CrowdPledgeService.new.payment_succeeded(crowd_pledge, payment_intent)
      Rails.logger.info "[stripe] CrowdPledgePaymentJob - erfolgreich abgeschlossen für CrowdPledge #{crowd_pledge.id}"
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "[stripe] CrowdPledgePaymentJob - Fehler beim Verarbeiten von CrowdPledge #{crowd_pledge.id}: #{e.message}"
      Sentry.capture_exception(e, extra: { crowd_pledge_id: crowd_pledge.id, payment_intent_id: payment_intent.id })
      # Optional: crowd_pledge.update(status: "failed")
    rescue => e
      Rails.logger.error "[stripe] CrowdPledgePaymentJob - Unerwarteter Fehler bei CrowdPledge #{crowd_pledge.id}: #{e.class} - #{e.message}"
      Sentry.capture_exception(e, extra: { crowd_pledge_id: crowd_pledge.id, payment_intent_id: payment_intent.id })
      raise # damit DelayedJob Retry-Strategie greift, falls konfiguriert
    end
  end
end
