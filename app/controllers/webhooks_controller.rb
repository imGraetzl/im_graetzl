class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    head :bad_request and return if params[:type].blank? || params[:id].blank?

    event = Stripe::Event.retrieve(params[:id])
    case event.type
    when "payment_intent.succeeded"
      payment_intent_succeded(event.data.object)
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
    end

    head :ok
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

  def payment_intent_succeded(payment_intent)
    if payment_intent.metadata["pledge_id"]
      crowd_pledge = CrowdPledge.find_by(id: payment_intent.metadata.pledge_id)
      if crowd_pledge
        CrowdPledgeService.new.payment_succeeded(crowd_pledge, payment_intent)
      end
    end

    if payment_intent.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: payment_intent.metadata.room_rental_id)
      RoomRentalService.new.payment_succeeded(room_rental, payment_intent) if room_rental
    end

    if payment_intent.metadata["tool_rental_id"]
      tool_rental = ToolRental.find_by(id: payment_intent.metadata.tool_rental_id)
      ToolRentalService.new.payment_succeeded(tool_rental, payment_intent) if tool_rental
    end

    if payment_intent.metadata["zuckerl_id"]
      zuckerl = Zuckerl.find_by(id: payment_intent.metadata.zuckerl_id)
      ZuckerlService.new.payment_succeeded(zuckerl, payment_intent) if zuckerl
    end

    if payment_intent.metadata["room_booster_id"]
      room_booster = RoomBooster.find_by(id: payment_intent.metadata.room_booster_id)
      RoomBoosterService.new.payment_succeeded(room_booster, payment_intent) if room_booster
    end

    if payment_intent.metadata["crowd_boost_charge_id"]
      crowd_boost_charge = CrowdBoostCharge.find_by(id: payment_intent.metadata.crowd_boost_charge_id)
      CrowdBoostService.new.payment_succeeded(crowd_boost_charge, payment_intent) if crowd_boost_charge
    end
  end

  def payment_intent_failed(payment_intent)
    if payment_intent.metadata["pledge_id"]
      crowd_pledge = CrowdPledge.find_by(id: payment_intent.metadata.pledge_id)
      CrowdPledgeService.new.payment_failed(crowd_pledge, payment_intent) if crowd_pledge
    end

    if payment_intent.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: payment_intent.metadata.room_rental_id)
      RoomRentalService.new.payment_failed(room_rental, payment_intent) if room_rental
    end

    if payment_intent.metadata["tool_rental_id"]
      tool_rental = ToolRental.find_by(id: payment_intent.metadata.tool_rental_id)
      ToolRentalService.new.payment_failed(tool_rental, payment_intent) if tool_rental
    end

    if payment_intent.metadata["zuckerl_id"]
      zuckerl = Zuckerl.find_by(id: payment_intent.metadata.zuckerl_id)
      ZuckerlService.new.payment_failed(zuckerl, payment_intent) if zuckerl
    end

    if payment_intent.metadata["room_booster_id"]
      room_booster = RoomBooster.find_by(id: payment_intent.metadata.room_booster_id)
      RoomBoosterService.new.payment_failed(room_booster, payment_intent) if room_booster
    end

    if payment_intent.metadata["crowd_boost_charge_id"]
      crowd_boost_charge = CrowdBoostCharge.find_by(id: payment_intent.metadata.crowd_boost_charge_id)
      CrowdBoostService.new.payment_failed(crowd_boost_charge, payment_intent) if crowd_boost_charge
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
    subscription = Subscription.find_by(stripe_id: object.subscription)
    SubscriptionService.new.invoice_paid(subscription, object) if subscription
    SubscriptionMailer.invoice(subscription).deliver_later if subscription
  end

  def invoice_upcoming(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    if subscription
      amount = object.amount_remaining / 100
      period_start = object.lines.data[0].period.start
      SubscriptionMailer.invoice_upcoming(subscription, amount, period_start).deliver_later
    end
  end

  def invoice_marked_uncollectible(object)
    invoice = SubscriptionInvoice.find_by(stripe_id: object.id)
    SubscriptionService.new.invoice_uncollectible(invoice, object) if invoice
  end

  def invoice_payment_action_required(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    payment_intent = Stripe::PaymentIntent.retrieve(object.payment_intent)

    if subscription && object.billing_reason != "subscription_create" && ["active"].include?(subscription.status)
      period_start = object.lines.data[0].period.start
      period_end = object.lines.data[0].period.end
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(object.payment_intent, subscription, period_start, period_end).deliver_later  
    end
  end

  def invoice_payment_failed(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    payment_intent = Stripe::PaymentIntent.retrieve(object.payment_intent)

    if subscription && object.attempt_count == 3
      SubscriptionMailer.invoice_payment_failed_final(subscription).deliver_later

    elsif subscription && object.billing_reason != "subscription_create" && ["requires_payment_method"].include?(payment_intent.status)
      period_start = object.lines.data[0].period.start
      period_end = object.lines.data[0].period.end
      SubscriptionService.new.invoice_payment_open(subscription, object)
      SubscriptionMailer.invoice_payment_failed(object.payment_intent, subscription, period_start, period_end).deliver_later

    end
  end

  def charge_refunded(charge)

    if charge.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: charge.metadata.room_rental_id)
      RoomRentalService.new.payment_refunded(room_rental) if room_rental
    
    elsif charge.metadata["tool_rental_id"]
      tool_rental = ToolRental.find_by(id: charge.metadata.tool_rental_id)
      ToolRentalService.new.payment_refunded(tool_rental) if tool_rental

    elsif charge.metadata["room_booster_id"]
      room_booster = RoomBooster.find_by(id: charge.metadata.room_booster_id)
      RoomBoosterService.new.payment_refunded(room_booster) if room_booster

    elsif charge.metadata["pledge_id"]
      crowd_pledge = CrowdPledge.find_by(id: charge.metadata.pledge_id)
      CrowdPledgeService.new.payment_refunded(crowd_pledge) if crowd_pledge

    elsif charge.invoice
      invoice = SubscriptionInvoice.find_by(stripe_id: charge.invoice)
      SubscriptionService.new.invoice_refunded(invoice, charge) if invoice

    elsif charge.metadata["zuckerl_id"]
      zuckerl = Zuckerl.find_by(id: charge.metadata.zuckerl_id)
      ZuckerlService.new.payment_refunded(zuckerl) if zuckerl

    elsif charge.metadata["crowd_boost_charge_id"]
      crowd_boost_charge = CrowdBoostCharge.find_by(id: charge.metadata.crowd_boost_charge_id)
      CrowdBoostService.new.payment_refunded(crowd_boost_charge) if crowd_boost_charge

    end

  end

end
