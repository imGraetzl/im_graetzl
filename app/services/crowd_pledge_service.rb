class CrowdPledgeService

  def create_setup_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: CrowdPledge::PAYMENT_METHODS,
      usage: 'off_session',
      metadata: {
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id
      },
    )
  end

  def card_payment_authorized(crowd_pledge, setup_intent_id)
    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    if setup_intent.payment_method.type.in?(['sofort', 'bancontact', 'ideal'])
      # These are one-time payment methods by default. When set up for future usage, they generate a
      # sepa_debit reusable payment method type
      payment_method_id = Stripe::PaymentMethod.list(customer: get_stripe_customer_id(crowd_pledge), type: 'sepa_debit').first.id
    else
      payment_method_id = setup_intent.payment_method.id
    end

    crowd_pledge.update(
      stripe_payment_method_id: payment_method_id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: setup_intent.payment_method.type == 'card' ? setup_intent.payment_method.card.last4 : nil,
      status: 'authorized',
    )

    crowd_pledge.crowd_reward&.increment!(:claimed)

    CrowdCampaignMailer.crowd_pledge_authorized(crowd_pledge).deliver_later
    ActionProcessor.track(crowd_pledge, :create)

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
      payment_method_types: CrowdPledge::PAYMENT_METHODS,
      payment_method: crowd_pledge.stripe_payment_method_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(crowd_pledge.crowd_campaign),
      metadata: {
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id
      },
      off_session: true,
      confirm: true,
    )

    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      status: 'debited',
    )

    CrowdCampaignMailer.crowd_pledge_debited(crowd_pledge).deliver_later

    { success: true }
  rescue Stripe::CardError
    crowd_pledge.update(status: 'failed')
    CrowdCampaignMailer.crowd_pledge_failed(crowd_pledge).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
  end

  def create_payment_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(crowd_pledge.crowd_campaign),
      payment_method_types: CrowdPledge::PAYMENT_METHODS,
      metadata: {
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id
      },
    )
  end

  def payment_retried(crowd_pledge, payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    if !payment_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      status: 'debited',
    )
    CrowdCampaignMailer.crowd_pledge_retried_debited(crowd_pledge).deliver_later
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

  def statement_descriptor(crowd_campaign)
    "#{crowd_campaign.region.host_id} Crowdfunding".upcase
  end

end
