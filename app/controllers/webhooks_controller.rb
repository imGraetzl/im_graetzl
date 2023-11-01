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
      payment_action_required(event.data.object)
    when "invoice.paid"
      invoice_paid(event.data.object)
    when "invoice.upcoming"
      invoice_upcoming(event.data.object)
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
        user = User.find_by_email(data['email'])
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
  end

  def subscription_updated(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.update_subscription(subscription, object) if subscription
  end

  def subscription_deleted(object)
    subscription = Subscription.find_by(stripe_id: object.id)
    SubscriptionService.new.delete_subscription(subscription, object) if subscription
  end

  def payment_action_required(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    SubscriptionMailer.payment_action_required(object.payment_intent, subscription).deliver_later if subscription
  end

  def invoice_paid(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    SubscriptionService.new.invoice_paid(subscription, object) if subscription
    SubscriptionMailer.invoice(subscription).deliver_later if subscription
  end

  def invoice_upcoming(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    amount = object.lines.data[0].amount / 100
    period_start = object.lines.data[0].period.start
    SubscriptionMailer.invoice_upcoming(subscription, amount, period_start).deliver_later if subscription
  end

  def invoice_payment_failed(object)
    subscription = Subscription.find_by(stripe_id: object.subscription)
    SubscriptionMailer.invoice_payment_failed(subscription).deliver_later if subscription
  end

  def charge_refunded(charge)
    if charge.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: charge.metadata.room_rental_id)
      RoomRentalService.new.payment_refunded(room_rental) if room_rental
    end

    if charge.metadata["tool_rental_id"]
      tool_rental = ToolRental.find_by(id: charge.metadata.tool_rental_id)
      ToolRentalService.new.payment_refunded(tool_rental) if tool_rental
    end

    if charge.metadata["room_booster_id"]
      room_booster = RoomBooster.find_by(id: charge.metadata.room_booster_id)
      RoomBoosterService.new.payment_refunded(room_booster) if room_booster
    end
  end

end
