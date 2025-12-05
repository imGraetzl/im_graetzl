namespace :stripe do
  desc "Backfill missing stripe_fee values for debited CrowdPledges"
  task backfill_crowdpledge_stripe_fees: :environment do
    require "stripe"

    RATE_LIMIT_SLEEP = 0.2
    MAX_RETRIES      = 3

    scope = CrowdPledge.debited
      .where(stripe_fee: nil)
      .where.not(stripe_payment_intent_id: nil)

    total = scope.count
    Sentry.logger.info("[Stripe Backfill] Starte Backfill für #{total} CrowdPledges")

    fees_set   = 0
    errors     = 0

    scope.find_each(batch_size: 50) do |cp|
      retries = 0

      begin
        sleep RATE_LIMIT_SLEEP
        pi = Stripe::PaymentIntent.retrieve(cp.stripe_payment_intent_id)

        charge_id = pi["latest_charge"]
        if charge_id.blank?
          Sentry.logger.warn("[Stripe Backfill] Kein latest_charge für CP #{cp.id}")
          errors += 1
          next
        end

        sleep RATE_LIMIT_SLEEP
        charge = Stripe::Charge.retrieve(charge_id)

        if charge.balance_transaction.blank?
          Sentry.logger.warn("[Stripe Backfill] Keine balance_transaction für Charge #{charge_id} (CP #{cp.id})")
          errors += 1
          next
        end

        sleep RATE_LIMIT_SLEEP
        bt = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)

        fee = bt.fee.to_d / 100
        cp.update!(stripe_fee: fee)

        fees_set += 1  # Erfolg wird nur internal gezählt, nicht geloggt

      rescue Stripe::RateLimitError
        retries += 1
        if retries <= MAX_RETRIES
          sleep(1.0 * retries)
          retry
        else
          Sentry.logger.warn("[Stripe Backfill] RateLimit dauerhaft gescheitert bei CP #{cp.id}")
          errors += 1
        end

      rescue Stripe::APIConnectionError => e
        retries += 1
        if retries <= MAX_RETRIES
          sleep(1.0 * retries)
          retry
        else
          Sentry.logger.warn("[Stripe Backfill] APIConnectionError bei CP #{cp.id}: #{e.message}")
          errors += 1
        end

      rescue Stripe::InvalidRequestError => e
        Sentry.logger.warn("[Stripe Backfill] InvalidRequestError bei CP #{cp.id}: #{e.message}")
        errors += 1

      rescue => e
        Sentry.logger.warn("[Stripe Backfill] Fehler bei CP #{cp.id}: #{e.class} – #{e.message}")
        errors += 1
      end
    end

    Sentry.logger.info("[Stripe Backfill] abgeschlossen – #{fees_set} Fees gesetzt, #{errors} Fehler")
  end
end