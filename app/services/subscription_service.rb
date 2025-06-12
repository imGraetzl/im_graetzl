class SubscriptionService

  def create(subscription, options={})
    stripe_customer_id = subscription.user.stripe_customer

    # coupon zu discounts mappen
    if options[:coupon].present?
      options[:discounts] ||= []
      options[:discounts] << { coupon: options.delete(:coupon) }
    end

    args = {
      customer: stripe_customer_id,
      items: [{ price: subscription.stripe_plan }],
      expand: ['latest_invoice'],
      payment_behavior: 'default_incomplete',
      metadata: {
        type: 'Subscription',
        subscription_id: subscription.id,
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(subscription.crowd_boost_charge_amount),
        crowd_boost_id: subscription.crowd_boost_id,
      },
      default_tax_rates: [
        Rails.application.config.stripe_default_tax_rates,
      ],
    }.merge(options)

    sub = Stripe::Subscription.create(
      args,
      {
        idempotency_key: "subscription_#{subscription.id}_create"
      }
    )
    
    item = sub.items.data.first
    subscription.update(
      stripe_id: sub.id,
      status: sub.status,
      ends_at: nil,
      current_period_start: Time.at(item.current_period_start),
      current_period_end: Time.at(item.current_period_end)
    )

    sub
  end

  def payment_authorized(subscription, payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] payment_authorized: PaymentIntent #{payment_intent_id} konnte nicht geladen werden: #{e.message}"
      return [false, "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless payment_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] payment_authorized: PaymentIntent #{payment_intent.id} hat ungültigen Status: #{payment_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    if payment_intent.payment_method.nil?
      Rails.logger.warn "[stripe] payment_authorized: PaymentIntent #{payment_intent.id} hat keine Payment-Methode"
      return [false, "Zahlungsmethode konnte nicht erkannt werden."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)

    true
  end


  def payment_changed(subscription, payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(id: payment_intent_id, expand: ['payment_method'])
    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] payment_changed: PaymentIntent #{payment_intent_id} konnte nicht geladen werden: #{e.message}"
      return [false, "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."]
    end

    unless payment_intent.status.in?(%w[succeeded processing])
      Rails.logger.warn "[stripe] payment_changed: PaymentIntent #{payment_intent.id} hat ungültigen Status: #{payment_intent.status}"
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    if payment_intent.payment_method.nil?
      Rails.logger.warn "[stripe] payment_changed: PaymentIntent #{payment_intent.id} hat keine verknüpfte Zahlungsmethode"
      return [false, "Zahlungsmethode konnte nicht gelesen werden."]
    end

    UserService.new.update_payment_method(subscription.user, payment_intent.payment_method.id)

    true
  end

  def finalize_invoice(subscription)
    return unless subscription.stripe_id

    begin
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
      invoice_id = stripe_subscription.latest_invoice
      return unless invoice_id

      invoice = Stripe::Invoice.retrieve(invoice_id)

      unless invoice.auto_advance
        Stripe::Invoice.update(invoice.id, auto_advance: true)
      end

      Stripe::Invoice.pay(invoice.id)

    rescue Stripe::InvalidRequestError => e
      Rails.logger.warn "[stripe] finalize_invoice: Fehler bei Subscription #{subscription.id}: #{e.message}"
    rescue => e
      Rails.logger.error "[stripe] finalize_invoice: Unerwarteter Fehler: #{e.class} – #{e.message}"
    end
  end

  def update_subscription(subscription, object)

    if object.status == "incomplete_expired"
      subscription.destroy
      return
    end

    subscription.status = object.status
    subscription.current_period_start = Time.at(object.current_period_start)
    subscription.current_period_end = Time.at(object.current_period_end)

    if object.ended_at
      subscription.ends_at = Time.at(object.ended_at)
    elsif object.cancel_at
      subscription.ends_at = Time.at(object.cancel_at)
    end

    subscription.save
  end

  def update_subscription(subscription, object)
    Rails.logger.info "[stripe webhook] Updating subscription #{subscription.id} (stripe_id=#{subscription.stripe_id})"
    Rails.logger.info "[stripe webhook] Subscription object keys: #{object.to_hash.keys}"

    first_item = object.items&.data&.first

    if object.status == "incomplete_expired"
      Rails.logger.info "[stripe webhook] Subscription is 'incomplete_expired', destroying local record."
      subscription.destroy
      return
    end

    subscription.status = object.status

    if first_item&.respond_to?(:current_period_start)
      subscription.current_period_start = Time.at(first_item.current_period_start)
    else
      Rails.logger.warn "[stripe webhook] current_period_start not found on first_item"
    end

    if first_item&.respond_to?(:current_period_end)
      subscription.current_period_end = Time.at(first_item.current_period_end)
    else
      Rails.logger.warn "[stripe webhook] current_period_end not found on first_item"
    end

    if object.ended_at
      subscription.ends_at = Time.at(object.ended_at)
    elsif object.cancel_at
      subscription.ends_at = Time.at(object.cancel_at)
    else
      subscription.ends_at = nil
    end

    if subscription.save
      Rails.logger.info "[stripe webhook] Subscription #{subscription.id} successfully updated."
    else
      Rails.logger.error "[stripe webhook] Failed to update subscription #{subscription.id}: #{subscription.errors.full_messages.join(', ')}"
    end
  end

  def delete_subscription(subscription, object)
    item = object.items&.data&.first
    subscription.update(
      status: object.status,
      ends_at: Time.at(object.ended_at),
      current_period_start: Time.at(item&.current_period_start),
      current_period_end: Time.at(item&.current_period_end),
    ) if object.ended_at.present?
  end

  def invoice_payment_open(subscription, object)
    user = subscription.user
    return if user.nil?
    return if user.subscription_invoices.exists?(stripe_id: object.id)

    coupon = nil
    begin
      if object[:subscription].present?
        stripe_subscription = ::Stripe::Subscription.retrieve(object[:subscription])
        stripe_coupon_id = stripe_subscription&.discount&.dig(:coupon, :id)
        coupon = Coupon.find_by(stripe_id: stripe_coupon_id) if stripe_coupon_id.present?
      end
    rescue => e
      Rails.logger.warn "[stripe webhook] Coupon konnte nicht geladen werden: #{e.message}"
    end

    if coupon
      CouponHistory.find_or_create_by(user: user, coupon: coupon)&.update(
        redeemed_at: Time.current,
        stripe_id: coupon.stripe_id
      )
    end

    user.subscription_invoices.create(
      subscription_id: subscription.id,
      crowd_boost_charge_amount: subscription.crowd_boost_charge_amount,
      crowd_boost_id: subscription.crowd_boost_id,
      stripe_id: object.id,
      status: object[:status],
      amount: object[:amount_due].to_f / 100.0,
      created_at: Time.at(object[:created]),
      invoice_pdf: object[:invoice_pdf],
      invoice_number: object[:number],
      stripe_payment_intent_id: object[:payment_intent],
      coupon_id: coupon&.id
    )
  end

  def invoice_refunded(subscription_invoice, object)
    subscription_invoice.update(
      status: 'refunded'
    )
  end

  def invoice_disputed(subscription_invoice, object)
    subscription_invoice.subscription.cancel_now!
    subscription_invoice.update(
      status: 'refunded'
    )
  end

  def invoice_uncollectible(subscription_invoice, object)
    subscription_invoice.update(
      status: 'uncollectible'
    )
  end

  def invoice_paid(subscription, object)
    user = subscription.user
    return if user.nil?

    coupon = nil

    # Versuche, Discount-ID aus der ersten Line Item Discount Amount zu ziehen
    begin
      lines = object[:lines]
      line_item = lines.respond_to?(:data) ? lines.data.first : nil
      discount_id = line_item&.discount_amounts&.first&.discount

      if discount_id.present?
        Rails.logger.info "[stripe webhook] invoice_paid: found discount_id #{discount_id}"
        coupon = Coupon.find_by(stripe_id: discount_id)

        if coupon
          Rails.logger.info "[stripe webhook] invoice_paid: matched coupon.id=#{coupon.id}"
          CouponHistory.find_or_create_by(user: user, coupon: coupon)&.update(
            redeemed_at: Time.current,
            stripe_id: coupon.stripe_id
          )
        else
          Rails.logger.warn "[stripe webhook] invoice_paid: Kein Coupon gefunden für Discount-ID #{discount_id}"
        end
      else
        Rails.logger.info "[stripe webhook] invoice_paid: Keine Discount-ID im Line Item gefunden"
      end
    rescue => e
      Rails.logger.warn "[stripe webhook] invoice_paid: Fehler beim Laden des Coupons: #{e.message}"
    end

    subscription_invoice = user.subscription_invoices.find_or_initialize_by(stripe_id: object.id)

    attributes = {
      subscription_id: subscription.id,
      crowd_boost_charge_amount: subscription.crowd_boost_charge_amount,
      crowd_boost_id: subscription.crowd_boost_id,
      stripe_id: object.id,
      status: object[:status],
      amount: object[:amount_paid].to_f / 100.0,
      created_at: Time.at(object[:created]),
      invoice_pdf: object[:invoice_pdf],
      invoice_number: object[:number],
      stripe_payment_intent_id: object[:payment_intent],
      coupon_id: coupon&.id
    }

    subscription_invoice.assign_attributes(attributes)
    subscription_invoice.save
  end

  def update_payment_intent(subscription)
    Stripe::PaymentIntent.update(
      subscription.stripe_payment_intent_id,
      metadata: {
        type: 'SubscriptionInvoice',
        subscription_invoice_id: subscription.id,
        crowd_boost_charge_amount: ActionController::Base.helpers.number_with_precision(subscription.crowd_boost_charge_amount),
        crowd_boost_id: subscription.crowd_boost_id,
      }
    )
  end
end
