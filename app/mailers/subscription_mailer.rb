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
      bcc: 'michael@imgraetzl.at',
    )
  end

  def invoice_payment_failed(payment_intent, subscription, period_start, period_end)
    @subscription = subscription
    @payment_intent = payment_intent
    @period_start = Time.at(period_start).to_datetime
    @period_end = Time.at(period_end).to_datetime
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-invoice-payment-failed")
    mail(
      subject: "Probleme beim Zahlungsvorgang deiner #{@region.host_domain_name} Fördermitgliedschaft - Bitte aktualisiere deine Zahlungsmethode",
      from: platform_email('no-reply'),
      to: @user.email,
      bcc: 'michael@imgraetzl.at',
    )
  end

  def invoice_payment_failed_final(subscription)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-invoice-payment-failed-final")
    mail(
      subject: "Deine #{@region.host_domain_name} Fördermitgliedschaft wurde leider storniert...",
      from: platform_email('no-reply'),
      to: @user.email,
      bcc: 'michael@imgraetzl.at',
    )
  end

end
