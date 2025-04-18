class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    head :bad_request and return if params[:type].blank? || params[:id].blank?

    begin
      if params[:account].present?
        # Event für verbundene Stripe-Accounts abrufen
        event = Stripe::Event.retrieve(params[:id], { stripe_account: params[:account] })
      else
        # Standard-Event für Hauptkonto abrufen
        event = Stripe::Event.retrieve(params[:id])
      end
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "[stripe webhook] Stripe Event Abruf fehlgeschlagen: #{e.message}"
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
    when "charge.dispute.closed"
      charge_dispute_closed(event.data.object)
    else
      Rails.logger.warn "[stripe webhook] Unhandled event type: #{event.type}"
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error "[stripe webhook] processing error: #{e.full_message}"
    head :internal_server_error
  end


  def stripe_connected
    head :bad_request and return if params[:type].blank? || params[:id].blank?

    begin
      if params[:account].present?
        # Event für verbundene Stripe-Accounts abrufen
        event = Stripe::Event.retrieve(params[:id], { stripe_account: params[:account] })
      else
        # Standard-Event für Hauptkonto abrufen
        event = Stripe::Event.retrieve(params[:id])
      end
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "[stripe webhook connected] Stripe Event Abruf fehlgeschlagen: #{e.message}"
      return head :bad_request
    end

    case event.type
    when "payout.paid"
      payout_paid(event.data.object, params[:account])
    else
      Rails.logger.warn "[stripe webhook connected] Unhandled event type: #{event.type}"
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
    handlers = {
      "pledge_id" => [CrowdPledge, CrowdPledgeService],
      "room_rental_id" => [RoomRental, RoomRentalService],
      "tool_rental_id" => [ToolRental, ToolRentalService],
      "zuckerl_id" => [Zuckerl, ZuckerlService],
      "room_booster_id" => [RoomBooster, RoomBoosterService],
      "crowd_boost_charge_id" => [CrowdBoostCharge, CrowdBoostService]
    }
  
    handlers.each do |meta_key, (model_class, service_class)|
      id = payment_intent.metadata[meta_key]
      next unless id.present?
  
      Rails.logger.info "[stripe webhook] Prüfe #{meta_key} mit ID #{id} → #{model_class.name}"
  
      record = model_class.find_by(id: id)
      if record
        Rails.logger.info "[stripe webhook] Starte payment_succeeded für #{model_class.name}##{id} via #{service_class.name}"
        service_class.new.payment_succeeded(record, payment_intent)
      else
        Rails.logger.warn "[stripe webhook] Kein #{model_class.name} mit ID #{id} gefunden für #{meta_key}"
      end
    end
  end

  def payment_intent_failed(payment_intent)
    handlers = {
      "pledge_id" => [CrowdPledge, CrowdPledgeService],
      "room_rental_id" => [RoomRental, RoomRentalService],
      "tool_rental_id" => [ToolRental, ToolRentalService],
      "zuckerl_id" => [Zuckerl, ZuckerlService],
      "room_booster_id" => [RoomBooster, RoomBoosterService],
      "crowd_boost_charge_id" => [CrowdBoostCharge, CrowdBoostService]
    }
  
    handlers.each do |meta_key, (model_class, service_class)|
      id = payment_intent.metadata[meta_key]
      next unless id.present?
  
      Rails.logger.info "[stripe webhook] Prüfe #{meta_key} mit ID #{id} → #{model_class.name}"
  
      record = model_class.find_by(id: id)
      if record
        Rails.logger.info "[stripe webhook] Starte payment_failed für #{model_class.name}##{id} via #{service_class.name}"
        service_class.new.payment_failed(record, payment_intent)
      else
        Rails.logger.warn "[stripe webhook] Kein #{model_class.name} mit ID #{id} gefunden für #{meta_key}"
      end
    end
  end  

  def subscription_updated(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.update_subscription(subscription, object) if subscription
  end

  def subscription_deleted(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.delete_subscription(subscription, object) if subscription
  end

  def invoice_paid(object)
    subscription_id = object.try(:subscription)
    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice.paid ohne zugehörige Subscription – wird ignoriert"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription
      Rails.logger.info "[stripe webhook] invoice.paid für Subscription##{subscription.id}"
      SubscriptionService.new.invoice_paid(subscription, object)
      SubscriptionMailer.invoice(subscription).deliver_later
    else
      Rails.logger.warn "[stripe webhook] invoice.paid: Subscription mit stripe_id #{subscription_id} nicht gefunden"
    end
  end

  def invoice_upcoming(object)
    subscription_id = object.try(:subscription)
    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice.upcoming: Kein subscription_id vorhanden – wird ignoriert"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice.upcoming: Keine Subscription gefunden für stripe_id #{subscription_id}"
      return
    end
  
    amount = (object.amount_remaining || 0) / 100.0
    period_start = object.lines&.data&.first&.period&.start
  
    if period_start.present?
      Rails.logger.info "[stripe webhook] invoice.upcoming: Reminder für Subscription##{subscription.id}, Start: #{period_start}, Betrag: €#{amount}"
      SubscriptionMailer.invoice_upcoming(subscription, amount, period_start).deliver_later
    else
      Rails.logger.warn "[stripe webhook] invoice.upcoming: Kein Zeitraum gefunden für Invoice #{object.id}"
    end
  end
  

  def invoice_marked_uncollectible(object)
    invoice = SubscriptionInvoice.find_by(stripe_id: object.id)
    SubscriptionService.new.invoice_uncollectible(invoice, object) if invoice
  end

  def invoice_payment_action_required(object)
    subscription_id = object.try(:subscription)
    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice.payment_action_required: Kein subscription_id vorhanden – wird ignoriert"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice.payment_action_required: Keine Subscription gefunden für stripe_id #{subscription_id}"
      return
    end
  
    if object.billing_reason != "subscription_create" && subscription.status == "active"
      period_start = object.lines&.data&.first&.period&.start
      period_end   = object.lines&.data&.first&.period&.end
  
      Rails.logger.info "[stripe webhook] invoice.payment_action_required für Subscription##{subscription.id}"
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(object.payment_intent, subscription, period_start, period_end).deliver_later
    else
      Rails.logger.info "[stripe webhook] invoice.payment_action_required: Keine Aktion notwendig"
    end
  end  

  def invoice_payment_failed(object)
    subscription_id = object.try(:subscription)
    if subscription_id.blank?
      Rails.logger.warn "[stripe webhook] invoice.payment_failed: Kein subscription_id vorhanden – wird ignoriert"
      return
    end
  
    subscription = Subscription.find_by(stripe_id: subscription_id)
    if subscription.nil?
      Rails.logger.warn "[stripe webhook] invoice.payment_failed: Keine Subscription gefunden für stripe_id #{subscription_id}"
      return
    end
  
    payment_intent = begin
      Stripe::PaymentIntent.retrieve(object.payment_intent)
    rescue => e
      Rails.logger.warn "[stripe webhook] invoice.payment_failed: PaymentIntent konnte nicht geladen werden (#{e.message})"
      nil
    end
  
    if object.attempt_count == 3
      Rails.logger.info "[stripe webhook] invoice.payment_failed: 3. Versuch – sende finale Zahlungsfehlermail"
      SubscriptionMailer.invoice_payment_failed_final(subscription).deliver_later

    elsif object.billing_reason != "subscription_create" && payment_intent&.status == "requires_payment_method"
  
      period_start = object.lines&.data&.first&.period&.start
      period_end   = object.lines&.data&.first&.period&.end
  
      Rails.logger.info "[stripe webhook] invoice.payment_failed: Zahlungsaufforderung an #{subscription.user.email} für Zeitraum #{period_start} – #{period_end}"
  
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(object.payment_intent, subscription, period_start, period_end).deliver_later
    else
      Rails.logger.info "[stripe webhook] invoice.payment_failed: Keine Aktion notwendig (Status: #{payment_intent&.status}, Attempt: #{object.attempt_count})"
    end
  end

  def charge_refunded(charge)
    handlers = {
      "room_rental_id"         => [RoomRental, RoomRentalService],
      "tool_rental_id"         => [ToolRental, ToolRentalService],
      "room_booster_id"        => [RoomBooster, RoomBoosterService],
      "pledge_id"              => [CrowdPledge, CrowdPledgeService],
      "zuckerl_id"             => [Zuckerl, ZuckerlService],
      "crowd_boost_charge_id"  => [CrowdBoostCharge, CrowdBoostService]
    }
  
    handled = false
  
    handlers.each do |meta_key, (model_class, service_class)|
      id = charge.metadata[meta_key]
      next unless id.present?
  
      Rails.logger.info "[stripe webhook] Prüfe #{meta_key} mit ID #{id} → #{model_class.name}"
      record = model_class.find_by(id: id)
  
      if record
        Rails.logger.info "[stripe webhook] Starte payment_refunded für #{model_class.name}##{id} via #{service_class.name}"
        service_class.new.payment_refunded(record)
        handled = true
        break
      else
        Rails.logger.warn "[stripe webhook] Kein #{model_class.name} mit ID #{id} gefunden für #{meta_key}"
      end
    end
  
    # Fallback: Abrechnung einer Subscription über Invoice-Referenz
    if !handled && charge.invoice.present?
      invoice = SubscriptionInvoice.find_by(stripe_id: charge.invoice)
      if invoice
        Rails.logger.info "[stripe webhook] Starte invoice_refunded für SubscriptionInvoice##{invoice.id}"
        SubscriptionService.new.invoice_refunded(invoice, charge)
      else
        Rails.logger.warn "[stripe webhook] Kein SubscriptionInvoice gefunden mit stripe_id=#{charge.invoice}"
      end
    end
  end
  

  def charge_dispute_closed(dispute)
    return unless dispute.status == 'lost'
  
    charge = begin
      Stripe::Charge.retrieve(id: dispute.charge)
    rescue => e
      Rails.logger.warn "[stripe webhook] charge_dispute_closed: Charge konnte nicht geladen werden (#{e.message})"
      return
    end
  
    if charge.invoice.present?
      invoice = SubscriptionInvoice.find_by(stripe_id: charge.invoice)
      if invoice
        Rails.logger.info "[stripe webhook] charge_dispute_closed: Dispute für Invoice##{invoice.id}"
        SubscriptionService.new.invoice_disputed(invoice, charge)
      else
        Rails.logger.warn "[stripe webhook] charge_dispute_closed: Kein Invoice-Record für #{charge.invoice}"
      end
  
    elsif charge.metadata["pledge_id"].present?
      crowd_pledge = CrowdPledge.find_by(id: charge.metadata["pledge_id"])
      if crowd_pledge
        Rails.logger.info "[stripe webhook] charge_dispute_closed: Dispute für CrowdPledge##{crowd_pledge.id}"
        CrowdPledgeService.new.payment_disputed(crowd_pledge)
      else
        Rails.logger.warn "[stripe webhook] charge_dispute_closed: Kein CrowdPledge für ID #{charge.metadata["pledge_id"]}"
      end
  
    else
      Rails.logger.warn "[stripe webhook] charge_dispute_closed: Kein passender Verweis in metadata oder invoice"
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
