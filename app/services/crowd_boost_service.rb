class CrowdBoostService

  include PaymentHelper

  def create_payment_intent(crowd_boost_charge)
    stripe_customer_id = get_stripe_customer_id(crowd_boost_charge)
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (crowd_boost_charge.amount * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(crowd_boost_charge),
      payment_method_types: payment_methods(crowd_boost_charge),
      metadata: {
        type: 'CrowdBoostCharge',
        crowd_boost_charge_id: crowd_boost_charge.id,
        crowd_boost_charge_amount: (crowd_boost_charge.amount * 100).to_i,
        crowd_boost_id: crowd_boost_charge.crowd_boost.id,
        region_id: crowd_boost_charge.region_id
      },
    )
  end

  def payment_authorized(crowd_boost_charge, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    crowd_boost_charge.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method.id,
      payment_method: payment_intent.payment_method.type,
      payment_card_last4: payment_method_last4(payment_intent.payment_method),
      payment_wallet: payment_wallet(payment_intent.payment_method),
      payment_status: 'authorized',
    )

    true
  end

  def payment_succeeded(crowd_boost_charge, payment_intent)
    crowd_boost_charge.update(payment_status: 'debited', debited_at: Time.current)

    generate_invoice(crowd_boost_charge)
    CrowdBoostMailer.crowd_boost_charge_invoice(crowd_boost_charge).deliver_later(wait: 1.minute)
    AdminMailer.new_crowd_boost_charge(crowd_boost_charge).deliver_later

    { success: true }
  end

  def payment_failed(crowd_boost_charge, payment_intent)
    crowd_boost_charge.update(payment_status: 'failed')

    { success: true }
  end

  def payment_refunded(crowd_boost_charge)
    crowd_boost_charge.update(payment_status: 'refunded')
    true
  end

  private

  def get_stripe_customer_id(crowd_boost_charge)
    return crowd_boost_charge.stripe_customer_id if crowd_boost_charge.stripe_customer_id.present?

    if crowd_boost_charge.user&.stripe_customer_id.present?
      crowd_boost_charge.update(stripe_customer_id: crowd_boost_charge.user.stripe_customer_id)
    else
      stripe_customer = Stripe::Customer.create(email: crowd_boost_charge.email)
      crowd_boost_charge.user.update(stripe_customer_id: stripe_customer.id) if crowd_boost_charge.user
      crowd_boost_charge.update(stripe_customer_id: stripe_customer.id)
    end

    crowd_boost_charge.stripe_customer_id
  end

  def payment_methods(crowd_boost_charge)
    ['card', 'eps']
  end

  def statement_descriptor(crowd_boost_charge)
    "#{crowd_boost_charge.region.host_id} BoostCharge".upcase
  end

  def generate_invoice(crowd_boost_charge)
    invoice_number = "#{Date.current.year}_CrowdBoostCharge_#{crowd_boost_charge.id}_#{CrowdBoostCharge.next_invoice_number}"
    crowd_boost_charge.update(invoice_number: invoice_number)
    crowd_boost_charge_invoice = CrowdBoostInvoice.new.invoice(crowd_boost_charge)
    crowd_boost_charge.invoice.put(body: crowd_boost_charge_invoice)
  end

end
