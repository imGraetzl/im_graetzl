class RoomBoosterService

  include PaymentHelper

  def create_payment_intent(room_booster)
    stripe_customer_id = room_booster.user.stripe_customer
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (room_booster.amount * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(room_booster),
      payment_method_types: payment_methods(room_booster),
      metadata: {
        type: 'RoomBooster',
        room_booster_id: room_booster.id,
        room_offer_id: room_booster.room_offer.id
      },
    )
  end

  def payment_authorized(room_booster, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    room_booster.update(
      stripe_payment_intent_id: payment_intent.id,
      stripe_payment_method_id: payment_intent.payment_method.id,
      payment_method: payment_intent.payment_method.type,
      payment_card_last4: payment_method_last4(payment_intent.payment_method),
      payment_wallet: payment_wallet(payment_intent.payment_method),
    )

    true
  end

  def payment_succeeded(room_booster, payment_intent)
    room_booster.update(payment_status: 'debited', debited_at: Time.current)

    if room_booster.starts_at_date == Date.today && room_booster.invoice_number.nil?
      room_booster.update(status: 'active')
      RoomBoosterService.new.delay.create(room_booster)
    else
      room_booster.update(status: 'pending')
    end

    generate_invoice(room_booster)
    RoomMailer.room_booster_invoice(room_booster).deliver_later(wait: 1.minute)
    AdminMailer.new_room_booster(room_booster).deliver_later

    { success: true }
  end

  def payment_failed(room_booster, payment_intent)
    room_booster.update(payment_status: 'failed', status: 'incomplete')

    { success: true }
  end

  def payment_refunded(room_booster)
    room_booster.update(payment_status: 'refunded', status: 'storno')
    ActionProcessor.track(room_booster.room_offer, :boost_refund, room_booster) # Raumteiler Activity Reset
    true
  end

  def create(room_booster)
    ActionProcessor.track(room_booster.room_offer, :boost_create, room_booster)
    room_booster.room_offer.update(last_activated_at: Time.now) # Raumteiler Pages PushUp
  end

  def start_pending(room_booster)
    room_booster.update(status: 'active')
    room_booster.room_offer.update(last_activated_at: Time.now) # Raumteiler Pages PushUp
    ActionProcessor.track(room_booster.room_offer, :boost_create, room_booster)
  end

  def create_for_free(room_booster)
    if room_booster.starts_at_date == Date.today
      room_booster.update(payment_status: 'free', status: 'active', amount: 0)
      ActionProcessor.track(room_booster.room_offer, :boost_create, room_booster)
      room_booster.room_offer.update(last_activated_at: Time.now) # Raumteiler Pages PushUp
    else
      room_booster.update(payment_status: 'free', status: 'pending', amount: 0)
    end
  end

  # Daily PushUp
  def push_up(room_booster)
    return if !room_booster.active? && !room_booster.room_offer
    ActionProcessor.track(room_booster.room_offer, :boost_pushup, room_booster) # Raumteiler Activity PushUp
    room_booster.room_offer.update(last_activated_at: Time.now) # Raumteiler Pages PushUp
  end

  def expire(room_booster)
    room_booster.update(status: 'expired')
    # Reset Activity to only Room Graetzls
    Activity.where(subject: room_booster.room_offer).update(graetzl_ids: room_booster.room_offer.graetzl.id)
  end

  private

  def payment_methods(room_booster)
    ['card', 'eps']
  end

  def statement_descriptor(room_booster)
    "#{room_booster.region.host_id} RoomBooster".upcase
  end

  def generate_invoice(room_booster)
    invoice_number = "#{Date.current.year}_RoomBooster-#{room_booster.id}_Nr-#{RoomBooster.next_invoice_number}"
    room_booster.update(invoice_number: invoice_number)
    room_booster_invoice = RoomBoosterInvoice.new.invoice(room_booster)
    room_booster.invoice.put(body: room_booster_invoice)
  end

end
