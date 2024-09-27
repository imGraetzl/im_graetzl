class RoomRentalService

  include PaymentHelper

  def create_setup_intent(room_rental)
    stripe_customer_id = room_rental.renter.stripe_customer
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: available_payment_methods(room_rental),
      usage: 'off_session',
      metadata: {
        type: 'RoomRental',
        room_rental_id: room_rental.id,
        room_offer_id: room_rental.room_offer.id
      },
    )
  end

  def payment_authorized(room_rental, setup_intent_id)
    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    room_rental.update(
      stripe_payment_method_id: setup_intent.payment_method.id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: payment_method_last4(setup_intent.payment_method),
      payment_wallet: payment_wallet(setup_intent.payment_method),
      payment_status: 'authorized',
      rental_status: :pending,
    )

    UserMessageThread.create_for_room_rental(room_rental)
    RoomMailer.new_rental_request(room_rental).deliver_later
    Notifications::RoomRentalCreated.generate(room_rental, to: { user: room_rental.owner.id })
    return { success: true }

  end

  def approve(room_rental)
    return if !room_rental.authorized?

    room_rental.update(payment_status: 'processing', rental_status: :approved)

    payment_intent = Stripe::PaymentIntent.create(
      customer: room_rental.renter.stripe_customer_id,
      payment_method_types: available_payment_methods(room_rental),
      payment_method: room_rental.stripe_payment_method_id,
      amount: (room_rental.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(room_rental.room_offer),
      metadata: {
        type: 'RoomRental',
        room_rental_id: room_rental.id,
        room_offer_id: room_rental.room_offer.id
      },
      off_session: true,
      confirm: true,
    )

    invoice_number = "#{Date.current.year}_RoomRental_#{RoomRental.next_invoice_number}"
    room_rental.update(
      stripe_payment_intent_id: payment_intent.id,
      rental_status: :approved,
      invoice_number: invoice_number
    )

    generate_invoices(room_rental)
    RoomMailer.rental_approved_renter(room_rental).deliver_later
    RoomMailer.rental_approved_owner(room_rental).deliver_later
    Notifications::RoomRentalApproved.generate(room_rental, to: { user: room_rental.renter.id })

    { success: true }
  rescue Stripe::CardError
    room_rental.update(payment_status: 'failed')
    RoomMailer.rental_payment_failed(room_rental).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
  end

  def payment_succeeded(room_rental, payment_intent)
    room_rental.update(payment_status: 'debited', debited_at: Time.current)

    { success: true }
  end

  def payment_failed(room_rental, payment_intent)
    return if !room_rental.processing?

    room_rental.update(payment_status: 'failed')
    RoomMailer.rental_payment_failed(room_rental).deliver_later

    { success: true }
  end

  def create_retry_intent(room_rental)
    stripe_customer_id = room_rental.renter.stripe_customer
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (room_rental.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(room_rental.room_offer),
      payment_method_types: retry_payment_methods(room_rental),
      metadata: {
        type: 'RoomRental',
        room_rental_id: room_rental.id,
        room_offer_id: room_rental.room_offer.id
      },
    )
  end

  def payment_retried(room_rental, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    room_rental.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method.id,
      payment_method: payment_intent.payment_method.type,
      payment_card_last4: payment_method_last4(payment_intent.payment_method),
      payment_wallet: payment_wallet(payment_intent.payment_method),
    )
    true
  end

  def payment_refunded(room_rental)
    room_rental.update(
      rental_status: :storno,
      payment_status: 'refunded',
    )
    true
  end

  def reject(room_rental)
    room_rental.rejected!
    RoomMailer.rental_rejected(room_rental).deliver_later
    Notifications::RoomRentalRejected.generate(room_rental, to: { user: room_rental.renter.id })
  end

  def cancel(room_rental)
    room_rental.canceled!
    RoomMailer.rental_canceled(room_rental).deliver_later
    Notifications::RoomRentalCanceled.generate(room_rental, to: { user: room_rental.owner.id })
  end

  def expire(room_rental)
    room_rental.expired!
  end

  private

  def available_payment_methods(room_rental)
    if room_rental.total_price <= 500
      ['card', 'sepa_debit']
    else
      ['card']
    end
  end

  def retry_payment_methods(room_rental)
    ['card', 'eps']
  end

  def statement_descriptor(room_offer)
    "#{room_offer.region.host_id} Raumteiler".upcase
  end

  def generate_invoices(room_rental)
    renter_invoice = RoomRentalInvoice.new.generate_for_renter(room_rental)
    room_rental.renter_invoice.put(body: renter_invoice)
    owner_invoice = RoomRentalInvoice.new.generate_for_owner(room_rental)
    room_rental.owner_invoice.put(body: owner_invoice)
  end

end
