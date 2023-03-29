class SubscriptionMailerPreview < ActionMailer::Preview

  def created
    SubscriptionMailer.created(Subscription.last)
  end

  def invoice
    SubscriptionMailer.invoice(Subscription.last)
  end

  def invoice_payment_failed
    SubscriptionMailer.invoice_payment_failed(Subscription.last)
  end

  def payment_action_required
    SubscriptionMailer.payment_action_required(Subscription.last)
  end

end
