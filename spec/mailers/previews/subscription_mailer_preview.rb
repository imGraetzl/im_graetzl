class SubscriptionMailerPreview < ActionMailer::Preview

  def created
    SubscriptionMailer.created(Subscription.last)
  end

  def invoice
    SubscriptionMailer.invoice(Subscription.last)
  end

  def invoice_upcoming
    SubscriptionMailer.invoice_upcoming(Subscription.last, Subscription.last.subscription_plan.amount, Time.now.to_i)
  end

  def invoice_payment_failed
    SubscriptionMailer.invoice_payment_failed('payment-intent-id', Subscription.last, Time.now.to_i, Time.now.to_i)
  end

  def invoice_payment_failed_on_create
    SubscriptionMailer.invoice_payment_failed_on_create(Subscription.last.user)
  end

  def invoice_payment_failed_final
    SubscriptionMailer.invoice_payment_failed_final(Subscription.last)
  end

end
