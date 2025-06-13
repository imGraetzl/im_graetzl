class UserService

  include PaymentHelper

  def create_setup_intent(user)
    Stripe::SetupIntent.create(
      {
        customer: user.stripe_customer,
        payment_method_types: ['card', 'sepa_debit'],
        usage: 'off_session'
      }
    )
  end

  def update_payment_method(user, payment_method_id)

    payment_method = Stripe::PaymentMethod.attach(payment_method_id, { customer: user.stripe_customer })
    Stripe::Customer.update(user.stripe_customer, invoice_settings: { default_payment_method: payment_method.id })

    user.update(
      payment_method_stripe_id: payment_method.id,
      payment_method: payment_method.type,
      payment_card_last4: payment_method_last4(payment_method),
      payment_wallet: payment_wallet(payment_method),
      payment_exp_month: payment_method.respond_to?(:card) ? payment_method.card&.exp_month : nil,
      payment_exp_year: payment_method.respond_to?(:card) ? payment_method.card&.exp_year : nil
    )
  end

  def payment_authorized(user, setup_intent_id)
    begin
      setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] SetupIntent konnte nicht geladen werden (#{setup_intent_id}): #{e.message}"
      return [false, "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless setup_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent.id} mit ungültigem Status: #{setup_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    if setup_intent.payment_method.nil?
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent.id} hat keine payment_method"
      return [false, "Zahlungsmethode konnte nicht verarbeitet werden."]
    end

    UserService.new.update_payment_method(user, setup_intent.payment_method.id)

    true
  end

  private

end
