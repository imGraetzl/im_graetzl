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
      }
    )
  end

  def payment_authorized(room_rental, setup_intent_id)
    begin
      setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] SetupIntent konnte nicht geladen werden: #{e.message}"
      return [false, "Ein technischer Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless setup_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] SetupIntent #{setup_intent.id} hat ungültigen Status: #{setup_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    payment_method = setup_intent.payment_method

    room_rental.update(
      stripe_payment_method_id: payment_method.id,
      payment_method: payment_method.type,
      payment_card_last4: payment_method_last4(payment_method),
      payment_wallet: payment_wallet(payment_method),
      payment_status: 'authorized',
      rental_status: :pending,
    )

    UserMessageThread.create_for_room_rental(room_rental)
    RoomMailer.new_rental_request(room_rental).deliver_later
    Notifications::RoomRentalCreated.generate(room_rental, to: { user: room_rental.owner.id })

    { success: true }
  end

  def approve(room_rental)
    return if !room_rental.authorized?
  
    room_rental.update(payment_status: 'processing', rental_status: :approved)
  
    payment_intent_id = nil
    payment_failed = false
  
    begin
      payment_intent = Stripe::PaymentIntent.create(
        {
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
        },
        {
          idempotency_key: "room_rental_#{room_rental.id}_charge"
        }
      )
      payment_intent_id = payment_intent.id
    rescue Stripe::CardError => e
      payment_failed = true
      payment_intent_id = e&.json_body&.dig(:error, :payment_intent, :id)
    end
  
    invoice_number = "#{Date.current.year}_RoomRental_#{RoomRental.next_invoice_number}"

    update_hash = {
      stripe_payment_intent_id: payment_intent_id,
      invoice_number: invoice_number
    }
    update_hash[:payment_status] = 'failed' if payment_failed

    room_rental.update(update_hash)
  
    generate_invoices(room_rental)
    RoomMailer.rental_approved_owner(room_rental).deliver_later
    RoomMailer.rental_approved_renter(room_rental).deliver_later
    Notifications::RoomRentalApproved.generate(room_rental, to: { user: room_rental.renter.id })
  
    if payment_failed
      RoomMailer.rental_payment_failed(room_rental).deliver_later
      return { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
    else
      return { success: true }
    end
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
      }
    )
  end

  def payment_retried(room_rental, payment_intent_id)
    payment_intent = begin
      Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] payment_intent #{payment_intent_id} konnte nicht geladen werden: #{e.message}"
      return [false, "Ein technischer Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless payment_intent.status.in?(%w[succeeded processing])
      Rails.logger.info "[stripe] PaymentIntent #{payment_intent.id} nicht erfolgreich (Status: #{payment_intent.status})"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    room_rental.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method&.id,
      payment_method: payment_intent.payment_method&.type,
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
    statement_descriptor_for(room_offer.region, 'Raumteiler')
  end

  def generate_invoices(room_rental)
    renter_invoice = RoomRentalInvoice.new.generate_for_renter(room_rental)
    room_rental.renter_invoice.put(body: renter_invoice)
    owner_invoice = RoomRentalInvoice.new.generate_for_owner(room_rental)
    room_rental.owner_invoice.put(body: owner_invoice)
  end

end
