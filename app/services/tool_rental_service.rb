class ToolRentalService

  include PaymentHelper

  def create_setup_intent(tool_rental)
    stripe_customer_id = tool_rental.renter.stripe_customer
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: available_payment_methods(tool_rental),
      usage: 'off_session',
      metadata: {
        type: 'ToolRental',
        tool_rental_id: tool_rental.id,
        tool_offer_id: tool_rental.tool_offer.id
      },
    )
  end

  def payment_authorized(tool_rental, setup_intent_id)
    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    tool_rental.update(
      stripe_payment_method_id: setup_intent.payment_method.id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: payment_method_last4(setup_intent.payment_method),
      payment_wallet: payment_wallet(setup_intent.payment_method),
      payment_status: 'authorized',
      rental_status: :pending,
    )

    UserMessageThread.create_for_tool_rental(tool_rental)
    ToolMailer.new_rental_request(tool_rental).deliver_later
    Notifications::ToolRentalCreated.generate(tool_rental, to: { user: tool_rental.owner.id })
    return { success: true }

  end

  def approve(tool_rental)
    return if !tool_rental.authorized?

    tool_rental.update(payment_status: 'processing')

    payment_intent = Stripe::PaymentIntent.create(
      customer: tool_rental.renter.stripe_customer_id,
      payment_method_types: available_payment_methods(tool_rental),
      payment_method: tool_rental.stripe_payment_method_id,
      amount: (tool_rental.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(tool_rental.tool_offer),
      metadata: {
        type: 'ToolRental',
        tool_rental_id: tool_rental.id,
        tool_offer_id: tool_rental.tool_offer.id
      },
      off_session: true,
      confirm: true,
    )

    invoice_number = "#{Date.current.year}_ToolRental_#{ToolRental.next_invoice_number}"
    tool_rental.update(
      stripe_payment_intent_id: payment_intent.id,
      rental_status: :approved,
      invoice_number: invoice_number
    )

    generate_invoices(tool_rental)
    ToolMailer.rental_approved(tool_rental).deliver_later
    Notifications::ToolRentalApproved.generate(tool_rental, to: { user: tool_rental.renter.id })

    { success: true }
  rescue Stripe::CardError
    tool_rental.update(payment_status: 'failed')
    ToolMailer.rental_payment_failed(tool_rental).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
  end

  def payment_succeeded(tool_rental, payment_intent)
    tool_rental.update(payment_status: 'debited', debited_at: Time.current)

    { success: true }
  end

  def payment_failed(tool_rental, payment_intent)
    return if !tool_rental.processing?

    tool_rental.update(payment_status: 'failed')
    ToolMailer.rental_payment_failed(tool_rental).deliver_later

    { success: true }
  end

  def create_retry_intent(tool_rental)
    stripe_customer_id = tool_rental.renter.stripe_customer
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (tool_rental.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(tool_rental.tool_offer),
      payment_method_types: retry_payment_methods(tool_rental),
      metadata: {
        type: 'ToolRental',
        tool_rental_id: tool_rental.id,
        tool_offer_id: tool_rental.tool_offer.id
      },
    )
  end

  def payment_retried(tool_rental, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    tool_rental.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method.id,
      payment_method: payment_intent.payment_method.type,
      payment_card_last4: payment_method_last4(payment_intent.payment_method),
      payment_wallet: payment_wallet(payment_intent.payment_method),
    )
    true
  end

  def payment_refunded(tool_rental)
    tool_rental.update(
      rental_status: :storno,
      payment_status: 'refunded',
    )
    true
  end

  def reject(tool_rental)
    tool_rental.rejected!
    ToolMailer.rental_rejected(tool_rental).deliver_later
    Notifications::ToolRentalRejected.generate(tool_rental, to: { user: tool_rental.renter.id })
  end

  def cancel(tool_rental)
    tool_rental.canceled!
    ToolMailer.rental_canceled(tool_rental).deliver_later
    Notifications::ToolRentalCanceled.generate(tool_rental, to: { users: tool_rental.owner.id })
  end

  def expire(tool_rental)
    tool_rental.expired!
  end

  def confirm_return(tool_rental)
    tool_rental.return_confirmed!
    ToolMailer.return_confirmed_owner(tool_rental).deliver_later
    ToolMailer.return_confirmed_renter(tool_rental).deliver_later
    Notifications::ToolRentalReturnConfirmed.generate(tool_rental, to: { users: tool_rental.renter.id })
  end

  private

  def available_payment_methods(tool_rental)
    if tool_rental.total_price <= 500
      ['card', 'sepa_debit']
    else
      ['card']
    end
  end

  def retry_payment_methods(tool_rental)
    ['card', 'eps']
  end

  def statement_descriptor(tool_offer)
    "#{tool_offer.region.host_id} Geräteteiler".upcase
  end

  def generate_invoices(tool_rental)
    renter_invoice = ToolRentalInvoice.new.generate_for_renter(tool_rental)
    tool_rental.renter_invoice.put(body: renter_invoice)
    owner_invoice = ToolRentalInvoice.new.generate_for_owner(tool_rental)
    tool_rental.owner_invoice.put(body: owner_invoice)
  end

end
