class CrowdPledgeService

  def create_setup_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: ['card'],
      usage: 'off_session',
    )
  end

  def card_payment_authorized(crowd_pledge, payment_method_id)
    card = Stripe::PaymentMethod.retrieve(payment_method_id).card

    crowd_pledge.update(
      stripe_payment_method_id: payment_method_id,
      payment_method: 'card',
      payment_card_last4: card.last4,
      status: 'authorized',
    )

    case crowd_pledge.crowd_campaign.check_funding
    when :goal_1_reached
      CrowdCampaignMailer.crowd_campaign_funding_1_successful(crowd_pledge.crowd_campaign).deliver_later
    when :goal_2_reached
      CrowdCampaignMailer.crowd_campaign_funding_2_successful(crowd_pledge.crowd_campaign).deliver_later
    end

    { success: true }
  end

  def charge(crowd_pledge)
    payment_intent = Stripe::PaymentIntent.create(
      customer: crowd_pledge.stripe_customer_id,
      payment_method: crowd_pledge.stripe_payment_method_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      off_session: true,
      confirm: true,
    )

    # TODO: Check if payment succeeded
    # Test with 4000002500003155 for success, 4000008260003178 for failure


    crowd_pledge.update(
      stripe_payment_intent_id: payment_intent.id,
      status: 'debited',
    )



    { success: true }
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
