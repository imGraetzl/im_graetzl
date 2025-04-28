class SubscriptionService

  def create(subscription, options={})
    stripe_customer_id = subscription.user.stripe_customer

    # coupon zu discounts mappen
    if options[:coupon].present?
      options[:discounts] ||= []
      options[:discounts] << { coupon: options.delete(:coupon) }
    end

    args = {
      customer: stripe_customer_id,
      items: [{ price: subscription.stripe_plan }],
      expand: ['latest_invoice'],
      payment_behavior: 'default_incomplete',
      metadata: {
        type: 'Subscription',
        subscription_id: subscription.id,
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(subscription.crowd_boost_charge_amount),
        crowd_boost_id: subscription.crowd_boost_id,
      },
      default_tax_rates: [
        Rails.application.config.stripe_default_tax_rates,
      ],
    }.merge(options)

    sub = Stripe::Subscription.create(
      args,
      {
        idempotency_key: "subscription_#{subscription.id}_create"
      }
    )
    
    item = sub.items.data.first
    subscription.update(
      stripe_id: sub.id,
      status: sub.status,
      ends_at: nil,
      current_period_start: Time.at(item.current_period_start),
      current_period_end: Time.at(item.current_period_end)
    )

    sub
  end

  def payment_authorized(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method&.id)

    true
  end

  def payment_changed(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method&.id)

    true
  end

  def finalize_invoice(subscription)
    return unless subscription.stripe_id
  
    stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
    invoice_id = stripe_subscription.latest_invoice
    return unless invoice_id
  
    invoice = Stripe::Invoice.retrieve(invoice_id)
  
    # Falls auto_advance noch nicht gesetzt ist, setze es!
    Stripe::Invoice.update(invoice.id, auto_advance: true) unless invoice.auto_advance
  
    # Zahle die Invoice sofort
    Stripe::Invoice.pay(invoice.id)
  end  

  def update_subscription(subscription, object)

    if object.status == "incomplete_expired"
      subscription.destroy
      return
    end

    subscription.status = object.status
    subscription.current_period_start = Time.at(object.current_period_start)
    subscription.current_period_end = Time.at(object.current_period_end)

    if object.ended_at
      subscription.ends_at = Time.at(object.ended_at)
    elsif object.cancel_at
      subscription.ends_at = Time.at(object.cancel_at)
    end

    subscription.save
  end

  def delete_subscription(subscription, object)
    item = object.items&.data&.first
    subscription.update(
      status: object.status,
      ends_at: Time.at(object.ended_at),
      current_period_start: Time.at(item&.current_period_start),
      current_period_end: Time.at(item&.current_period_end),
    ) if object.ended_at.present?
  end

  def invoice_payment_open(subscription, object)

    user = subscription.user
    return if user.nil?
    return if user.subscription_invoices.where(stripe_id: object.id).any?

    # Coupon aus dem Stripe-Response extrahieren
    stripe_coupon_id = object.discount&.coupon&.id
    coupon = Coupon.find_by(stripe_id: stripe_coupon_id) if stripe_coupon_id.present?
    CouponHistory.find_or_create_by(user: user, coupon: coupon)&.update(redeemed_at: Time.current, stripe_id: coupon.stripe_id) if coupon

    user.subscription_invoices.create(
      subscription_id: subscription.id,
      crowd_boost_charge_amount: subscription.crowd_boost_charge_amount,
      crowd_boost_id: subscription.crowd_boost_id,
      stripe_id: object.id,
      status:object.status,
      amount:object.amount_due / 100,
      created_at: Time.at(object.created),
      invoice_pdf: object.invoice_pdf,
      invoice_number: object.number,
      stripe_payment_intent_id: object.payment_intent,
      coupon_id: coupon&.id # Zuweisung der Coupon-ID, falls vorhanden
    )
  end

  def invoice_refunded(subscription_invoice, object)
    subscription_invoice.update(
      status: 'refunded'
    )
  end

  def invoice_disputed(subscription_invoice, object)
    subscription_invoice.subscription.cancel_now!
    subscription_invoice.update(
      status: 'refunded'
    )
  end

  def invoice_uncollectible(subscription_invoice, object)
    subscription_invoice.update(
      status: 'uncollectible'
    )
  end

  def invoice_paid(subscription, object)
    user = subscription.user
    return if user.nil?

    # Coupon aus dem Stripe-Response extrahieren
    stripe_coupon_id = object.discount&.coupon&.id
    coupon = Coupon.find_by(stripe_id: stripe_coupon_id) if stripe_coupon_id.present?
    CouponHistory.find_or_create_by(user: user, coupon: coupon)&.update(redeemed_at: Time.current, stripe_id: coupon.stripe_id) if coupon
  
    subscription_invoice = user.subscription_invoices.find_or_initialize_by(stripe_id: object.id)

    attributes = {
      subscription_id: subscription.id,
      crowd_boost_charge_amount: subscription.crowd_boost_charge_amount,
      crowd_boost_id: subscription.crowd_boost_id,
      stripe_id: object.id,
      status: object.status,
      amount: object.amount_paid / 100.0, # Betrag in Euro
      created_at: Time.at(object.created), # Timestamp von Stripe
      invoice_pdf: object.invoice_pdf,
      invoice_number: object.number,
      stripe_payment_intent_id: object.payment_intent,
      coupon_id: coupon&.id # Zuweisung der Coupon-ID, falls vorhanden
    }
  
    subscription_invoice.assign_attributes(attributes)
    subscription_invoice.save
  end

  def update_payment_intent(subscription)
    Stripe::PaymentIntent.update(
      subscription.stripe_payment_intent_id,
      metadata: {
        type: 'SubscriptionInvoice',
        subscription_invoice_id: subscription.id,
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(subscription.crowd_boost_charge_amount),
        crowd_boost_id: subscription.crowd_boost_id,
      }
    )
  end
end
