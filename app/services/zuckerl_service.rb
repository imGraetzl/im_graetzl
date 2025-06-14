class ZuckerlService

  include PaymentHelper

  def create_setup_intent(zuckerl)

    if zuckerl.crowd_boost_charge_amount && zuckerl.crowd_boost_charge_amount > 0
      CrowdBoostService.new.create_charge_from(zuckerl)
    end

    stripe_customer_id = zuckerl.user.stripe_customer
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: available_payment_methods(zuckerl),
      usage: 'off_session',
      metadata: {
        type: 'Zuckerl',
        zuckerl_id: zuckerl.id,
        location_id: zuckerl.location&.id,
        user_id: zuckerl.user.id
      }
    )
  end


  def payment_authorized(zuckerl, setup_intent_id)
    begin
      setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] SetupIntent konnte nicht geladen werden (#{setup_intent_id}): #{e.message}"
      return [false, "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless setup_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent.id} hat ungültigen Status: #{setup_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    payment_method = setup_intent.payment_method

    zuckerl.update(
      stripe_payment_method_id: payment_method.id,
      payment_method: payment_method.type,
      payment_card_last4: payment_method_last4(payment_method),
      payment_wallet: payment_wallet(payment_method),
      payment_status: 'authorized',
    )

    zuckerl.pending!
    AdminMailer.new_zuckerl(zuckerl).deliver_later

    true
  end

  def approve(zuckerl)
    return if !zuckerl.pending?

    zuckerl.approve! if zuckerl.may_approve?
    ZuckerlService.new.charge(zuckerl) if zuckerl.authorized?
    ZuckerlMailer.approved(zuckerl).deliver_later

  end

  def invoice(zuckerl)
    generate_invoice(zuckerl)
    ZuckerlMailer.invoice(zuckerl).deliver_later(wait: 1.minute)
  end

  def publish(zuckerl)
    zuckerl.live! if zuckerl.may_live?
    ZuckerlMailer.live(zuckerl).deliver_later
  end


  def charge(zuckerl)
    return if !zuckerl.authorized?

    zuckerl.update(payment_status: 'processing')

    payment_intent = Stripe::PaymentIntent.create(
      {
        customer: zuckerl.user.stripe_customer_id,
        payment_method_types: available_payment_methods(zuckerl),
        payment_method: zuckerl.stripe_payment_method_id,
        amount: (zuckerl.amount * 100).to_i,
        currency: 'eur',
        statement_descriptor: statement_descriptor(zuckerl),
        metadata: {
          type: 'Zuckerl',
          zuckerl_id: zuckerl.id,
          location_id: zuckerl.location&.id,
          user_id: zuckerl.user.id,
          crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(zuckerl.crowd_boost_charge_amount),
          crowd_boost_id: zuckerl.crowd_boost_id,
        },
        off_session: true,
        confirm: true,
      },
      {
        idempotency_key: "zuckerl_#{zuckerl.id}_charge"
      }
    )

    zuckerl.update(stripe_payment_intent_id: payment_intent.id)

    { success: true }
  rescue Stripe::CardError
    zuckerl.update(payment_status: 'failed')
    ZuckerlMailer.payment_failed(zuckerl).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
  end

  def payment_succeeded(zuckerl, payment_intent)
    zuckerl.update(payment_status: 'debited', debited_at: Time.current)
    ZuckerlService.new.invoice(zuckerl)

    { success: true }
  end

  def payment_failed(zuckerl, payment_intent)
    return if !zuckerl.processing?

    zuckerl.update(payment_status: 'failed')
    ZuckerlMailer.payment_failed(zuckerl).deliver_later

    zuckerl.approve! if zuckerl.live? # Change State back to Approved if Zuckerl was already live

    { success: true }
  end

  def create_retry_intent(zuckerl)
    stripe_customer_id = zuckerl.user.stripe_customer
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (zuckerl.amount * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(zuckerl),
      payment_method_types: retry_payment_methods(zuckerl),
      metadata: {
        type: 'Zuckerl',
        zuckerl_id: zuckerl.id,
        location_id: zuckerl.location&.id,
        user_id: zuckerl.user.id,
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(zuckerl.crowd_boost_charge_amount),
        crowd_boost_id: zuckerl.crowd_boost_id,
      }
    )
  end

  def payment_retried(zuckerl, payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] PaymentIntent konnte nicht geladen werden (#{payment_intent_id}): #{e.message}"
      return [false, "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless payment_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] PaymentIntent #{payment_intent.id} mit ungültigem Status: #{payment_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    payment_method = payment_intent.payment_method

    zuckerl.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_method&.id,
      payment_method: payment_method&.type,
      payment_card_last4: payment_method_last4(payment_method),
      payment_wallet: payment_wallet(payment_method),
    )

    true
  end

  def payment_refunded(zuckerl)
    zuckerl.update(payment_status: 'refunded', aasm_state: 'storno')
    true
  end

  private

  def available_payment_methods(zuckerl)
    ['card', 'sepa_debit']
  end

  def retry_payment_methods(zuckerl)
    ['card', 'eps']
  end

  def statement_descriptor(zuckerl)
    statement_descriptor_for(zuckerl.region, 'Zuckerl')
  end

  def generate_invoice(zuckerl)
    invoice_number = "#{Date.current.year}_Zuckerl-#{zuckerl.id}_Nr-#{Zuckerl.next_invoice_number}"
    zuckerl.update(invoice_number: invoice_number)
    zuckerl_invoice = ZuckerlInvoice.new.invoice(zuckerl)
    zuckerl.zuckerl_invoice.put(body: zuckerl_invoice)
  end

end
