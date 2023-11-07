class SubscriptionService

  def create(subscription, options={})
    stripe_customer_id = subscription.user.stripe_customer

    args = {
      customer: stripe_customer_id,
      items: [{ plan: subscription.stripe_plan }],
      expand: ['latest_invoice.payment_intent'],
      payment_behavior: 'default_incomplete',
      metadata: {
        type: 'Subscription',
        subscription_id: subscription.id,
      },
      default_tax_rates: [
        Rails.application.config.stripe_default_tax_rates,
      ],
    }.merge(options)

    sub = Stripe::Subscription.create(args)

    subscription.update(
      stripe_id: sub.id,
      status: sub.status,
      ends_at: nil,
      current_period_start: Time.at(sub.current_period_start),
      current_period_end: Time.at(sub.current_period_end),
      coupon: sub&.discount&.coupon&.id,
    )

    sub
  end

  def payment_authorized(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)

    true
  end

  def payment_changed(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)

    true
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
    subscription.update(
      status: object.status,
      ends_at: Time.at(object.ended_at),
      current_period_start: Time.at(object.current_period_start),
      current_period_end: Time.at(object.current_period_end),
    ) if object.ended_at.present?
  end

  def invoice_payment_action_required(subscription, object)

    user = subscription.user
    return if user.nil?
    return if user.subscription_invoices.where(stripe_id: object.id).any?

    user.subscription_invoices.create(
      subscription_id: subscription.id,
      stripe_id: object.id,
      status:object.status,
      amount:object.amount_due / 100,
      created_at: Time.at(object.created),
      invoice_pdf: object.invoice_pdf,
      invoice_number: object.number,
      stripe_payment_intent_id: object.payment_intent,
    )
  end

  def invoice_refunded(subscription_invoice, object)
    subscription_invoice.update(
      status: 'refunded'
    )
  end

  def invoice_paid(subscription, object)
    user = subscription.user
    return if user.nil?

    if user.subscription_invoices.where(stripe_id: object.id).any?
      subscription_invoice = user.subscription_invoices.where(stripe_id: object.id)
      subscription_invoice.update_all(
        subscription_id: subscription.id,
        stripe_id: object.id,
        status:object.status,
        amount:object.amount_paid / 100,
        created_at: Time.at(object.created),
        invoice_pdf: object.invoice_pdf,
        invoice_number: object.number,
        stripe_payment_intent_id: object.payment_intent,
      )
    else
      user.subscription_invoices.create(
        subscription_id: subscription.id,
        stripe_id: object.id,
        status:object.status,
        amount:object.amount_paid / 100,
        created_at: Time.at(object.created),
        invoice_pdf: object.invoice_pdf,
        invoice_number: object.number,
        stripe_payment_intent_id: object.payment_intent,
      )
    end
    
  end

  def valid_coupon?(coupon)
    return false unless coupon.present?
    coupon_retrieved = Stripe::Coupon.retrieve(coupon)
    coupon_retrieved.valid == true
  rescue => error
    false
  end

  private

end
