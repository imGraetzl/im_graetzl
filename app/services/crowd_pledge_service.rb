class CrowdPledgeService

  def create_setup_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: CrowdPledge::PAYMENT_METHODS,
      usage: 'off_session',
    )
  end

  def card_payment_authorized(crowd_pledge, setup_intent_id)
    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Your payment was not successful, please try again."]
    end

    crowd_pledge.update(
      stripe_payment_method_id: setup_intent.payment_method.id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: setup_intent.payment_method.card&.last4,
      status: 'authorized',
    )

    crowd_pledge.crowd_reward&.increment!(:claimed)

    CrowdCampaignMailer.crowd_pledge_confirmation(crowd_pledge).deliver_later
    # ActionProcessor.track(@crowd_pledge, :create)

    case crowd_pledge.crowd_campaign.check_funding
    when :goal_1_reached
      CrowdCampaignMailer.goal_1_reached(crowd_pledge.crowd_campaign).deliver_later
    when :goal_2_reached
      CrowdCampaignMailer.goal_2_reached(crowd_pledge.crowd_campaign).deliver_later
    end

    true
  end

  def charge(crowd_pledge)
    # Test with 4000002500003155 for success, 4000008260003178 for failure
    payment_intent = Stripe::PaymentIntent.create(
      customer: crowd_pledge.stripe_customer_id,
      payment_method: crowd_pledge.stripe_payment_method_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      off_session: true,
      confirm: true,
    )

    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      status: 'debited',
    )

    CrowdCampaignMailer.crowd_pledge_completed_successful(crowd_pledge).deliver_later

    { success: true }
  rescue Stripe::CardError
    crowd_pledge.update(status: 'failed')
    CrowdCampaignMailer.crowd_pledge_payment_failed(crowd_pledge).deliver_later

    { success: false, error: "Charge failed." }
  end

  def create_payment_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      payment_method_types: CrowdPledge::PAYMENT_METHODS,
    )
  end

  def payment_retried(crowd_pledge, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Your payment was not successful, please try again."]
    end

    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      status: 'debited',
    )
    CrowdCampaignMailer.crowd_pledge_completed_successful(crowd_pledge).deliver_later
    true
  end

  private

  def get_stripe_customer_id(crowd_pledge)
    return crowd_pledge.stripe_customer_id if crowd_pledge.stripe_customer_id.present?

    if crowd_pledge.user&.stripe_customer_id.present?
      crowd_pledge.update(stripe_customer_id: crowd_pledge.user.stripe_customer_id)
    else
      stripe_customer = Stripe::Customer.create(email: crowd_pledge.email)
      crowd_pledge.user.update(stripe_customer_id: stripe_customer.id) if crowd_pledge.user
      crowd_pledge.update(stripe_customer_id: stripe_customer.id)
    end

    crowd_pledge.stripe_customer_id
  end

end
