class SubscriptionService

  def subscribe(subscription, options={})
    stripe_customer_id = subscription.user.stripe_customer

    args = {
      customer: stripe_customer_id,
      items: [{ plan: subscription.stripe_plan }],
      expand: ['latest_invoice.payment_intent'],
      payment_behavior: 'default_incomplete',
      metadata: {
        subscription_id: subscription.id,
      },
    }.merge(options)

    sub = Stripe::Subscription.create(args)

    subscription.update(
      stripe_id: sub.id,
      status: sub.status,
      ends_at: nil,
    )

    sub
  end

  def payment_authorized(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)
    #subscription.update(status: 'active') # Update via Webhook

    true
  end

  def payment_changed(subscription, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)
    #subscription.update(status: 'active') # Update via Webhook

    true
  end

  def update_subscription(subscription, object)

    if object.status == "incomplete_expired"
      subscription.destroy
      return
    end

    subscription.status = object.status

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
      ends_at: Time.at(object.ended_at)
    ) if object.ended_at.present?
  end

  def invoice_paid(subscription, object)
    user = subscription.user
    return if user.nil?
    return if user.subscription_invoices.where(stripe_id: object.id).any?

    user.subscription_invoices.create(
      stripe_id: object.id,
      status:object.status,
      created_at: Time.at(object.created),
      invoice_pdf: object.invoice_pdf,
      invoice_number: object.number,
    )
  end

  private

end
