class UserService

  def create_setup_intent(user)
    Stripe::SetupIntent.create(
      customer: user.stripe_customer,
      payment_method_types: ['card', 'sepa_debit'],
      usage: 'off_session',
    )
  end

  def update_payment_method(user, payment_method_id)

    payment_method = Stripe::PaymentMethod.attach(payment_method_id, { customer: user.stripe_customer })
    Stripe::Customer.update(user.stripe_customer, invoice_settings: { default_payment_method: payment_method.id })

    user.update(
      payment_method: payment_method.type,
      payment_card_last4: payment_method_last4(payment_method)
    )
  end

  def payment_authorized(user, setup_intent_id)

    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    UserService.new.update_payment_method(user, setup_intent.payment_method.id)

    true
  end

  private

  def payment_method_last4(payment_method)
    if payment_method.type == 'card'
      payment_method.card.last4
    elsif payment_method.type == 'sepa_debit'
      payment_method.sepa_debit.last4
    else
      nil
    end
  end

end
