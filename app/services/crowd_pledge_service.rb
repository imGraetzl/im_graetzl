class CrowdPledgeService

  include PaymentHelper

  def create_setup_intent(crowd_pledge)

    CrowdCampaignMailer.crowd_pledge_incomplete(crowd_pledge).deliver_later(wait: 5.minutes)

    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: available_payment_methods(crowd_pledge),
      usage: 'off_session',
      metadata: {
        type: 'CrowdPledge',
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id
      }
    )
  end

  def payment_authorized(crowd_pledge, setup_intent_id)
    setup_intent = begin
      Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent_id} konnte nicht geladen werden: #{e.message}"
      return [false, "Ein technischer Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless setup_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent_id} nicht erfolgreich (Status: #{setup_intent.status})"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    crowd_pledge.update(
      stripe_payment_method_id: setup_intent.payment_method.id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: payment_method_last4(setup_intent.payment_method),
      payment_wallet: payment_wallet(setup_intent.payment_method),
      status: 'authorized',
      authorized_at: Time.current
    )

    crowd_pledge.crowd_reward&.increment!(:claimed)

    CrowdCampaignMailer.crowd_pledge_authorized(crowd_pledge).deliver_later(wait: 2.minutes)
    ActionProcessor.track(crowd_pledge, :create)

    case crowd_pledge.crowd_campaign.check_boosting
    when :boost_authorized
      boost_amount = crowd_pledge.crowd_campaign.crowd_boost_slot.calculate_boost(crowd_pledge.crowd_campaign)

      crowd_boost_pledge = CrowdBoostPledge.create(
        amount: boost_amount,
        status: "authorized",
        crowd_campaign_id: crowd_pledge.crowd_campaign.id,
        crowd_boost_id: crowd_pledge.crowd_campaign.crowd_boost.id,
        crowd_boost_slot_id: crowd_pledge.crowd_campaign.crowd_boost_slot.id,
        region_id: crowd_pledge.region_id
      )

      if crowd_boost_pledge
        crowd_pledge.crowd_campaign.update(boost_status: 'boost_authorized')
        ActionProcessor.track(crowd_boost_pledge, :create)
        CrowdCampaignMailer.boost_authorized(crowd_boost_pledge.crowd_campaign, crowd_boost_pledge).deliver_later
      end
      
    end

    case crowd_pledge.crowd_campaign.check_funding
    when :goal_1_reached
      CrowdCampaignMailer.goal_1_reached(crowd_pledge.crowd_campaign).deliver_later

      if crowd_pledge.crowd_campaign.funding_2_amount.present? && (crowd_pledge.crowd_campaign.remaining_days > 2)
        pledges = crowd_pledge.crowd_campaign.crowd_pledges.authorized
        pledges = pledges.uniq { |s| s.email }
        pledges.each do |pledge|
          CrowdCampaignMailer.crowd_pledge_goal_1_reached(pledge).deliver_later
        end
      end

    when :goal_2_reached
      CrowdCampaignMailer.goal_2_reached(crowd_pledge.crowd_campaign).deliver_later
    end

    true
  end

  def charge(crowd_pledge)
    return unless crowd_pledge.authorized?

    crowd_pledge.update(status: 'processing')

    payment_intent = Stripe::PaymentIntent.create(
      {
        customer: crowd_pledge.stripe_customer_id,
        payment_method_types: available_payment_methods(crowd_pledge),
        payment_method: crowd_pledge.stripe_payment_method_id,
        amount: (crowd_pledge.total_overall_price * 100).to_i,
        currency: 'eur',
        statement_descriptor: statement_descriptor(crowd_pledge.crowd_campaign),
        metadata: {
          type: 'CrowdPledge',
          pledge_id: crowd_pledge.id,
          campaign_id: crowd_pledge.crowd_campaign.id,
          total_price: ActionController::Base.helpers.number_with_precision(crowd_pledge.total_price),
          crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(crowd_pledge.crowd_boost_charge_amount),
          crowd_boost_id: crowd_pledge.crowd_boost_id
        },
        off_session: true,
        confirm: true,
      }
    )

    crowd_pledge.update(stripe_payment_intent_id: payment_intent.id)
    CrowdCampaignMailer.crowd_pledge_debited(crowd_pledge).deliver_later

    { success: true }

  rescue Stripe::CardError => e
    crowd_pledge.update(status: 'failed', failed_at: Time.current)
    CrowdCampaignMailer.crowd_pledge_failed(crowd_pledge).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }

  rescue Stripe::InvalidRequestError => e
    log_and_notify_stripe_error(e, crowd_pledge, "InvalidRequestError")

    { success: false, error: "Zahlung konnte nicht durchgeführt werden – ungültige Stripe-Anfrage." }

  rescue Stripe::StripeError => e
    log_and_notify_stripe_error(e, crowd_pledge, "StripeError")

    { success: false, error: "Ein Fehler bei der Zahlung ist aufgetreten. Bitte versuche es später erneut." }

  rescue => e
    log_and_notify_stripe_error(e, crowd_pledge, "UnexpectedError")

    { success: false, error: "Ein unerwarteter Fehler ist aufgetreten." }
  end

  def payment_succeeded(crowd_pledge, payment_intent)
    stripe_fee = nil

    charge_id = payment_intent["latest_charge"]
    if charge_id.blank?
      Rails.logger.warn "[stripe] CrowdPledge #{crowd_pledge.id} - Kein latest_charge im PaymentIntent #{payment_intent['id']} – speichere trotzdem CrowdPledge als debited."
    else
      begin
        charge = Stripe::Charge.retrieve(charge_id)

        if charge.balance_transaction.present?
          begin
            balance_transaction = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
            stripe_fee = balance_transaction.fee.to_d / 100
          rescue Stripe::InvalidRequestError => e
            Rails.logger.warn "[stripe] CrowdPledge #{crowd_pledge.id} - balance_transaction konnte nicht geladen werden für Charge #{charge_id}: #{e.message}"
          end
        else
          Rails.logger.warn "[stripe] CrowdPledge #{crowd_pledge.id} - Charge #{charge_id} hat keine balance_transaction"
        end
      rescue Stripe::InvalidRequestError => e
        Rails.logger.warn "[stripe] CrowdPledge #{crowd_pledge.id} - Charge #{charge_id} konnte nicht geladen werden: #{e.message}"
      end
    end

    updates = { stripe_fee: stripe_fee }

    if crowd_pledge.disputed? || crowd_pledge.dispute_status.present?
      updates[:debited_at] = Time.current if crowd_pledge.debited_at.blank?
      Rails.logger.info "[stripe] CrowdPledge #{crowd_pledge.id} - Stripe fee aktualisiert, Status bleibt aufgrund offener Anfechtung unverändert."
    else
      updates[:status] = 'debited'
      updates[:debited_at] = Time.current
      Rails.logger.info "[stripe] CrowdPledge #{crowd_pledge.id} - als debited gespeichert#{stripe_fee ? " (fee: #{stripe_fee} EUR)" : ' (ohne fee)'}."
    end

    crowd_pledge.update(updates)

    { success: true }
  end

  def payment_failed(crowd_pledge, payment_intent)
    return if !crowd_pledge.processing?

    crowd_pledge.update(status: 'failed', failed_at: Time.current)
    CrowdCampaignMailer.crowd_pledge_failed(crowd_pledge).deliver_later

    { success: true }
  end

  def create_retry_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (crowd_pledge.total_overall_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(crowd_pledge.crowd_campaign),
      payment_method_types: retry_payment_methods(crowd_pledge),
      metadata: {
        type: 'CrowdPledge',
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id,
        total_price: ActionController::Base.helpers.number_with_precision(crowd_pledge.total_price),
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(crowd_pledge.crowd_boost_charge_amount),
        crowd_boost_id: crowd_pledge.crowd_boost_id
      }
    )
  end

  def payment_retried(crowd_pledge, payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] PaymentIntent konnte nicht geladen werden (#{payment_intent_id}): #{e.message}"
      return [false, "Zahlung konnte nicht überprüft werden. Bitte versuche es erneut."]
    end

    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method&.id,
      payment_method: payment_intent.payment_method&.type,
      payment_card_last4: payment_method_last4(payment_intent.payment_method),
      payment_wallet: payment_wallet(payment_intent.payment_method),
    )

    CrowdCampaignMailer.crowd_pledge_retried_debited(crowd_pledge).deliver_later

    true
  end


  def payment_refunded(crowd_pledge)
    crowd_pledge.update(status: 'refunded')
    true
  end

  def payment_dispute_opened(crowd_pledge, stripe_dispute)
    persist_open_dispute_state(crowd_pledge, stripe_dispute)
    Rails.logger.info "[CrowdPledgeService]: payment_dispute_opened: CrowdPledge #{crowd_pledge.id} (Stripe Dispute #{stripe_dispute.id})"

    true
  end

  def payment_dispute_updated(crowd_pledge, stripe_dispute)
    if dispute_closed_status?(stripe_dispute.status)
      return payment_dispute_closed(crowd_pledge, stripe_dispute)
    end

    persist_open_dispute_state(crowd_pledge, stripe_dispute)
    Rails.logger.info "[CrowdPledgeService]: payment_dispute_updated: CrowdPledge #{crowd_pledge.id} (Stripe Dispute #{stripe_dispute.id}, Status #{stripe_dispute.status})"

    true
  end

  def payment_dispute_closed(crowd_pledge, stripe_dispute)
    case stripe_dispute.status
    when 'lost', 'warning_closed'
      crowd_pledge.update(
        status: 'failed',
        dispute_status: stripe_dispute.status
      )
      Rails.logger.info "[CrowdPledgeService]: payment_dispute_closed: CrowdPledge #{crowd_pledge.id} marked failed (Stripe Dispute #{stripe_dispute.id})"
    when 'won'
      updates = {
        status: 'debited',
        dispute_status: 'won'
      }
      updates[:debited_at] = Time.current if crowd_pledge.debited_at.blank?
      crowd_pledge.update(updates)
      Rails.logger.info "[CrowdPledgeService]: payment_dispute_closed: CrowdPledge #{crowd_pledge.id} restored to debited (Stripe Dispute #{stripe_dispute.id})"
    else
      Rails.logger.warn "[CrowdPledgeService]: payment_dispute_closed: Unsupported dispute status #{stripe_dispute.status} for CrowdPledge #{crowd_pledge.id}"
      return false
    end

    true
  end

  def charge_updated(crowd_pledge, charge)
    stripe_fee = nil

    if !crowd_pledge.stripe_fee.present? && charge.balance_transaction.present?
      begin
        balance_transaction = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
        stripe_fee = balance_transaction.fee.to_d / 100
        Rails.logger.info "[CrowdPledgeService]: charge_updated: Stripe fee für CrowdPledge #{crowd_pledge.id} gespeichert: #{stripe_fee} EUR"
      rescue Stripe::InvalidRequestError => e
        Rails.logger.warn "[CrowdPledgeService]: charge_updated: Stripe fee konnte nicht geladen werden – #{e.message}"
      end
    else
      Rails.logger.warn "[CrowdPledgeService]: charge_updated: Stripe fee für CrowdPledge #{crowd_pledge.id} konnte nicht gespeichert werden – keine balance_transaction vorhanden"
    end

    crowd_pledge.update(stripe_fee: stripe_fee)

    { success: true }
  end


  private

  def persist_open_dispute_state(crowd_pledge, _stripe_dispute)
    updates = {
      status: 'disputed',
      dispute_status: 'open'
    }
    updates[:disputed_at] = Time.current if crowd_pledge.disputed_at.blank?
    crowd_pledge.update(updates)
  end

  def dispute_closed_status?(status)
    %w[won lost warning_closed].include?(status)
  end

  def get_stripe_customer_id(crowd_pledge)
    return crowd_pledge.stripe_customer_id if crowd_pledge.stripe_customer_id.present?

    if crowd_pledge.user&.stripe_customer_id.present?
      # Zugehöriger Pledge User hat bereits stripe_customer_id
      Rails.logger.info "[CrowdPledgeService]: get_stripe_customer_id: Zugehöriger Pledge User hat bereits stripe_customer_id: #{crowd_pledge.user.email}"
      crowd_pledge.update(stripe_customer_id: crowd_pledge.user.stripe_customer_id)

    elsif crowd_pledge.user.present?
      # Zugehöriger Pledge User ohne stripe_customer_id -> Wird nun erstellt
      Rails.logger.info "[CrowdPledgeService]: get_stripe_customer_id: Zugehöriger Pledge User ohne stripe_customer_id:  Wird nun erstellt: #{crowd_pledge.user.email}"
      crowd_pledge.update(stripe_customer_id: crowd_pledge.user.stripe_customer)

    else
      # Legacy Fallback (Bevor es Guest User gab)
      Rails.logger.info "[CrowdPledgeService]: get_stripe_customer_id: Legacy Fallback: Create stripe_customer_id without User for #{crowd_pledge.email}"
      stripe_customer = Stripe::Customer.create(email: crowd_pledge.email)
      crowd_pledge.update(stripe_customer_id: stripe_customer.id)
    end

    crowd_pledge.stripe_customer_id
  end

  def available_payment_methods(crowd_pledge)
    if crowd_pledge.total_price <= 1000
      ['card', 'sepa_debit']
    else
      ['card']
    end
  end

  def retry_payment_methods(crowd_pledge)
    ['card', 'eps']
  end

  def statement_descriptor(crowd_campaign)
    statement_descriptor_for(crowd_campaign.region, 'Crowdfunding')
  end

  def log_and_notify_stripe_error(e, crowd_pledge, error_type)
    Rails.logger.error "[stripe] CrowdPledge #{crowd_pledge.id} - #{error_type}: #{e.class} - #{e.message}"

    Sentry.capture_exception(e, extra: {
      crowd_pledge_id: crowd_pledge.id,
      stripe_customer_id: crowd_pledge.stripe_customer_id,
      stripe_payment_method_id: crowd_pledge.stripe_payment_method_id,
      stripe_payment_intent_id: crowd_pledge.stripe_payment_intent_id,
      total_price: crowd_pledge.total_overall_price,
      error_type: error_type
    })
  end

end
