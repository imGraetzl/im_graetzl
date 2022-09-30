class SubscriptionMailer < ApplicationMailer

  def payment_action_required(payment_intent_id, subscription)
    @payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    @subscription = subscription
    @user = @subscription.user
    @region = @subscription.region
    headers("X-MC-Tags" => "subscription-payment-action-required")
    mail(
      subject: "Bitte überprüfe deine Zahlungsmethode",
      from: platform_email('no-reply'),
      to: @user.email,
    )
  end

end
