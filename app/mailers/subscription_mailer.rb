class SubscriptionMailer < ApplicationMailer

  def created(subscription)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-created")
    mail(
      subject: "Danke für deine #{@region.host_domain_name} Fördermitgliedschaft",
      from: platform_email('no-reply'),
      to: @user.email,
    )
  end

  def invoice(subscription)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-invoice")
    mail(
      subject: "Deine #{@region.host_domain_name} Fördermitgliedschaft wurde bezahlt, anbei deine Rechnung",
      from: platform_email('no-reply'),
      to: @user.email,
    )
  end

  def invoice_upcoming(subscription, amount, period_start)
    @subscription = subscription
    @period_start = Time.at(period_start).to_datetime
    @amount = amount
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-invoice-upcoming")
    mail(
      subject: "Deine #{@region.host_domain_name} Fördermitgliedschaft wird am #{I18n.localize(@period_start, format:'%d. %B')} verlängert.",
      from: platform_email('no-reply'),
      to: @user.email,
    )
  end

  def invoice_payment_failed(subscription)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-invoice-payment-failed")
    mail(
      subject: "#{@region.host_domain_name} Fördermitgliedschaft Zahlung fehlgeschlagen - Bitte versuche es erneut.",
      from: platform_email('no-reply'),
      to: @user.email,
      bcc: 'michael@imgraetzl.at',
    )
  end

  def payment_action_required(payment_intent_id, subscription)
    @payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-payment-action-required")
    mail(
      subject: "#{@region.host_domain_name} Fördermitgliedschaft Zahlung fehlgeschlagen - Bitte überprüfe deine Zahlungsmethode",
      from: platform_email('no-reply'),
      to: @user.email,
      bcc: 'michael@imgraetzl.at',
    )
  end

end
