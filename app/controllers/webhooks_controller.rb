class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error "[stripe webhook] Invalid event: #{e.message}"
      return head :bad_request
    end

    case event.type
    when "payment_intent.succeeded"
      payment_intent_succeeded(event.data.object)
    when "payment_intent.payment_failed"
      payment_intent_failed(event.data.object)
    when "customer.subscription.updated"
      subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      subscription_deleted(event.data.object)
    when "invoice.payment_action_required"
      invoice_payment_action_required(event.data.object)
    when "invoice.payment_failed"
      invoice_payment_failed(event.data.object)
    when "invoice.paid"
      invoice_paid(event.data.object)
    when "invoice.upcoming"
      invoice_upcoming(event.data.object)
    when "invoice.marked_uncollectible"
      invoice_marked_uncollectible(event.data.object)
    when "charge.refunded"
      charge_refunded(event.data.object)
    when "charge.updated"
      charge_updated(event.data.object)
    when "charge.dispute.closed"
      charge_dispute_closed(event.data.object)
    else
      Rails.logger.info "[stripe webhook] Unhandled event type: #{event.type}"
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error "[stripe webhook] processing error: #{e.full_message}"
    head :internal_server_error
  end

  def stripe_connected
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_CONNECTED_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error "[stripe webhook connected] Invalid event: #{e.message}"
      return head :bad_request
    end

    case event.type
    when "payout.paid"
      payout_paid(event.data.object, event.account)
    else
      Rails.logger.info "[stripe webhook connected] Unhandled event type: #{event.type}"
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error "[stripe webhook connected] processing error: #{e.full_message}"
    head :internal_server_error
  end

  def mailchimp
    if request.get?
      render plain: 'Hello, Mailchimp!' # Verify Webhook Address
    elsif request.post? && params[:type].present? && params[:data].present?
      type, data = params['type'], params['data']
      if type == 'unsubscribe'
        user = User.registered.find_by_email(data['email'])
        user.update(newsletter: false) if !user.nil?
      end
    end
  end

  private

  def payment_intent_succeeded(payment_intent)
    type = payment_intent.metadata&.[]("type")
  
    case type
    when "CrowdPledge"
      if (id = payment_intent.metadata["pledge_id"]) && (record = CrowdPledge.find_by(id: id))
        CrowdPledgePaymentJob.perform_later(record.id, payment_intent.id)
      end
  
    when "RoomRental"
      if (id = payment_intent.metadata["room_rental_id"]) && (record = RoomRental.find_by(id: id))
        RoomRentalService.new.payment_succeeded(record, payment_intent)
      end
    
    when "RoomBooster"
      if (id = payment_intent.metadata["room_booster_id"]) && (record = RoomBooster.find_by(id: id))
        RoomBoosterService.new.payment_succeeded(record, payment_intent)
      end
  
    when "Zuckerl"
      if (id = payment_intent.metadata["zuckerl_id"]) && (record = Zuckerl.find_by(id: id))
        ZuckerlService.new.payment_succeeded(record, payment_intent)
      end
  
    when "CrowdBoostCharge"
      if (id = payment_intent.metadata["crowd_boost_charge_id"]) && (record = CrowdBoostCharge.find_by(id: id))
        CrowdBoostService.new.payment_succeeded(record, payment_intent)
      end
  
    else
      Rails.logger.info "[stripe webhook] payment_intent_succeeded: Unhandled metadata type: #{type.inspect}"
    end
  end  


  def payment_intent_failed(payment_intent)
    type = payment_intent.metadata&.[]("type")
  
    case type
    when "CrowdPledge"
      if (id = payment_intent.metadata["pledge_id"]) && (record = CrowdPledge.find_by(id: id))
        CrowdPledgeService.new.payment_failed(record, payment_intent)
      end
  
    when "RoomRental"
      if (id = payment_intent.metadata["room_rental_id"]) && (record = RoomRental.find_by(id: id))
        RoomRentalService.new.payment_failed(record, payment_intent)
      end
    
    when "Zuckerl"
      if (id = payment_intent.metadata["zuckerl_id"]) && (record = Zuckerl.find_by(id: id))
        ZuckerlService.new.payment_failed(record, payment_intent)
      end
  
    when "RoomBooster"
      if (id = payment_intent.metadata["room_booster_id"]) && (record = RoomBooster.find_by(id: id))
        RoomBoosterService.new.payment_failed(record, payment_intent)
      end
  
    when "CrowdBoostCharge"
      if (id = payment_intent.metadata["crowd_boost_charge_id"]) && (record = CrowdBoostCharge.find_by(id: id))
        CrowdBoostService.new.payment_failed(record, payment_intent)
      end
  
    else
      Rails.logger.info "[stripe webhook] payment_intent_failed: Unhandled metadata type: #{type.inspect}"
    end
  end  
  

  def subscription_updated(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.update_subscription(subscription, object) if subscription
    Rails.logger.info "[stripe webhook] subscription_updated: subscription: #{subscription&.id}"
  end

  def subscription_deleted(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.delete_subscription(subscription, object) if subscription
    Rails.logger.info "[stripe webhook] subscription_deleted: subscription: #{subscription&.id}"
  end

  def invoice_paid(object)
    extractor = Stripe::InvoiceDataExtractor.new(object)
    subscription_id = extractor.subscription_id

    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice_paid: no subscription found – ignoring"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription
      Rails.logger.info "[stripe webhook] invoice_paid: subscription: #{subscription&.id}"
      SubscriptionService.new.invoice_paid(subscription, object)
      SubscriptionMailer.invoice(subscription).deliver_later
    else
      Rails.logger.warn "[stripe webhook] invoice_paid: no subscription found with stripe_id #{subscription_id}"
    end
  end

  def invoice_upcoming(object)
    extractor = Stripe::InvoiceDataExtractor.new(object)
    subscription_id = extractor.subscription_id

    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice_upcoming: no subscription found – ignoring"
      return
    end

    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice_upcoming: no subscription found with stripe_id #{subscription_id}"
      return
    end

    period_start = extractor.period_start
    amount = extractor.amount_eur

    if period_start.present?
      Rails.logger.info "[stripe webhook] invoice_upcoming: Reminder for subscription #{subscription&.id}, period_start: #{Time.at(period_start)}, amount: €#{amount}"
      SubscriptionMailer.invoice_upcoming(subscription, amount, period_start).deliver_later
    else
      Rails.logger.warn "[stripe webhook] invoice_upcoming: no period_start found for subscription #{subscription&.id}, object: #{object[:id]}"
    end
  end

  def invoice_marked_uncollectible(object)
    invoice = SubscriptionInvoice.find_by(stripe_id: object.id)
    SubscriptionService.new.invoice_uncollectible(invoice, object) if invoice
    Rails.logger.info "[stripe webhook] invoice_marked_uncollectible: invoice: #{invoice&.id}"
  end

  def invoice_payment_action_required(object)
    extractor = Stripe::InvoiceDataExtractor.new(object)
    subscription_id = extractor.subscription_id

    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice_payment_action_required: no subscription found – ignoring"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice_payment_action_required: no subscription found with stripe_id #{subscription_id}"
      return
    end
  
    if object.billing_reason == "subscription_cycle" && subscription.status == "active"
      period_start = object.lines&.data&.first&.period&.start
      period_end   = object.lines&.data&.first&.period&.end
  
      Rails.logger.info "[stripe webhook] invoice_payment_action_required: subscription: #{subscription&.id}: PaymentIntent: #{object[:payment_intent]}"
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(object[:payment_intent], subscription, period_start, period_end).deliver_later
    else
      Rails.logger.info "[stripe webhook] invoice_payment_action_required: no action needed for subscription #{subscription&.id} (billing_reason: #{object.billing_reason}, status: #{subscription&.status})"
    end
  end  

  def invoice_payment_failed(object)
    extractor = Stripe::InvoiceDataExtractor.new(object)
    subscription_id = extractor.subscription_id
    
    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice_payment_failed: no subscription found – ignoring"
      return
    end

    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice_payment_failed: no subscription found with stripe_id #{subscription_id}"
      return
    end

    # Failed on Create
    if object.billing_reason == "subscription_create"
      Rails.logger.info "[stripe webhook] invoice_payment_failed: subscription: #{subscription&.id}: scheduled email invoice_payment_failed_on_create for #{subscription.user.email}"
      SubscriptionMailer.invoice_payment_failed_on_create(subscription.user).deliver_later(wait: 1.minute)

    # Failed bei Verlängerung 1. Versuch -> Mail
    elsif object.billing_reason == "subscription_cycle" && object.attempt_count == 1
      line = object.lines&.data&.first
      period_start = line&.period&.start
      period_end   = line&.period&.end

      Rails.logger.info "[stripe webhook] invoice_payment_failed: subscription: #{subscription&.id}: Verlängerung 1. Versuch: Zahlungsaufforderung an #{subscription.user.email} für Zeitraum #{period_start} – #{period_end}"
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(subscription, period_start, period_end).deliver_later(wait: 1.minute)

    # Failed bei Verlängerung 3. Versuch -> Mail Storno
    elsif object.billing_reason == "subscription_cycle" && object.attempt_count == 3
      Rails.logger.info "[stripe webhook] invoice_payment_failed: subscription: #{subscription&.id}: Verlängerung 3. Versuch: Subscription canceled for #{subscription.user.email}"
      SubscriptionMailer.invoice_payment_failed_final(subscription).deliver_later

    else
      Rails.logger.info "[stripe webhook] invoice_payment_failed: subscription: #{subscription&.id}: Keine Aktion notwendig (Status: #{payment_intent&.status}, Attempt: #{object.attempt_count})"
    end
  end

  def charge_refunded(charge)
    type = charge.metadata&.[]("type")
    handled = false
  
    case type
    when "CrowdPledge"
      if (id = charge.metadata["pledge_id"]) && (record = CrowdPledge.find_by(id: id))
        CrowdPledgeService.new.payment_refunded(record)
        handled = true
      end
  
    when "RoomRental"
      if (id = charge.metadata["room_rental_id"]) && (record = RoomRental.find_by(id: id))
        RoomRentalService.new.payment_refunded(record)
        handled = true
      end
    
    when "RoomBooster"
      if (id = charge.metadata["room_booster_id"]) && (record = RoomBooster.find_by(id: id))
        RoomBoosterService.new.payment_refunded(record)
        handled = true
      end
  
    when "Zuckerl"
      if (id = charge.metadata["zuckerl_id"]) && (record = Zuckerl.find_by(id: id))
        ZuckerlService.new.payment_refunded(record)
        handled = true
      end
  
    when "CrowdBoostCharge"
      if (id = charge.metadata["crowd_boost_charge_id"]) && (record = CrowdBoostCharge.find_by(id: id))
        CrowdBoostService.new.payment_refunded(record)
        handled = true
      end
    end
  
    # Fallback für Subscriptions via Invoice-Referenz
    invoice_id = charge.try(:invoice) || charge["invoice"]
    if !handled && invoice_id.present?
      invoice = SubscriptionInvoice.find_by(stripe_id: invoice_id)
      if invoice
        Rails.logger.info "[stripe webhook] charge_refunded: SubscriptionInvoice: #{invoice.id}"
        SubscriptionService.new.invoice_refunded(invoice, charge)
      else
        Rails.logger.warn "[stripe webhook] charge_refunded: No SubscriptionInvoice found with stripe_id=#{invoice_id}"
      end
    end

  end

  def charge_updated(charge)
    type = charge.metadata&.[]("type")  
    case type
    when "CrowdPledge"
      if (id = charge.metadata["pledge_id"]) && (record = CrowdPledge.find_by(id: id))
        CrowdPledgeService.new.charge_updated(record, charge)
      end
    end
  end

  def charge_dispute_closed(dispute)
    # Nur reagieren, wenn der Dispute verloren wurde
    return unless dispute.status == 'lost'
  
    charge = begin
      Stripe::Charge.retrieve(id: dispute.charge, expand: ["payment_intent"])
    rescue => e
      Rails.logger.warn "[stripe webhook] charge_dispute_closed: Charge konnte nicht geladen werden (#{e.message})"
      return
    end
  
    type = charge.metadata&.[]("type")
    handled = false
  
    case type
    when "CrowdPledge"
      if (id = charge.metadata["pledge_id"]) && (record = CrowdPledge.find_by(id: id))
        Rails.logger.info "[stripe webhook] charge_dispute_closed: Dispute for CrowdPledge##{id}"
        CrowdPledgeService.new.payment_disputed(record)
        handled = true
      end
    end
  
    # Fallback für SubscriptionInvoice via PaymentIntent
    if !handled && charge.payment_intent.present?
      payment_intent_id = charge.payment_intent.id
      invoice = SubscriptionInvoice.find_by(stripe_payment_intent_id: payment_intent_id)

      if invoice
        Rails.logger.info "[stripe webhook] charge_dispute_closed: Dispute for SubscriptionInvoice##{invoice.id} (via PaymentIntent)"
        SubscriptionService.new.invoice_disputed(invoice, charge)
        handled = true
      else
        Rails.logger.warn "[stripe webhook] charge_dispute_closed: Keine SubscriptionInvoice für PaymentIntent #{payment_intent_id}"
      end
    end

    if !handled
      Rails.logger.warn "[stripe webhook] charge_dispute_closed: Kein passender Verweis in metadata, invoice oder payment_intent"
      Rails.logger.warn "[stripe webhook] charge_dispute_closed: charge data: #{charge.to_json}"
    end

  end
  

  def payout_paid(object, account)
    Rails.logger.info "[stripe webhook connected] Incoming Payout for Account: #{account}"
    campaign = CrowdCampaign.payout_processing.joins(:user).where(users: { stripe_connect_account_id: account }).first
    
    if campaign
      campaign.update(transfer_status: 'payout_completed', payout_completed_at: Time.current)
      Rails.logger.info "[stripe webhook connected] Payout for Campaign: #{campaign.id}"
    else
      Rails.logger.info "[stripe webhook connected] No Campaign Found for: #{account}"
    end
  end

end
