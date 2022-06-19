class CrowdPledgeService

  def create_setup_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::SetupIntent.create(
      customer: stripe_customer_id,
      payment_method_types: available_payment_methods(crowd_pledge),
      usage: 'off_session',
      metadata: {
        pledge_id: crowd_pledge.id,
        campaign_id: crowd_pledge.crowd_campaign.id
      },
    )
  end

  def payment_authorized(crowd_pledge, setup_intent_id)
    setup_intent = Stripe::SetupIntent.retrieve(id: setup_intent_id, expand: ['payment_method'])
    if !setup_intent.status.in?(["succeeded", "processing"])
      return [false, "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut."]
    end

    crowd_pledge.update(
      stripe_payment_method_id: setup_intent.payment_method.id,
      payment_method: setup_intent.payment_method.type,
      payment_card_last4: payment_method_last4(setup_intent.payment_method),
      status: 'authorized',
    )

    crowd_pledge.crowd_reward&.increment!(:claimed)

    CrowdCampaignMailer.crowd_pledge_authorized(crowd_pledge).deliver_later
    ActionProcessor.track(crowd_pledge, :create)

    case crowd_pledge.crowd_campaign.check_funding
    when :goal_1_reached
      CrowdCampaignMailer.goal_1_reached(crowd_pledge.crowd_campaign).deliver_later

      if crowd_pledge.crowd_campaign.funding_2_amount.present?
        pledges = crowd_pledge.crowd_campaign.crowd_pledges.authorized
        pledges = pledges.uniq { |s| s.email }
        pledges.each do |pledge|
          CrowdCampaignMailer.crowd_pledge_goal_1_reached(pledge).deliver_later
        end
      end

    when :goal_2_reached
      CrowdCampaignMailer.goal_2_reached(crowd_pledge.crowd_campaign).deliver_later
    end

    true
  end

  def charge(crowd_pledge)
    return if !crowd_pledge.authorized?

    crowd_pledge.update(status: 'processing')

    payment_intent = Stripe::PaymentIntent.create(
      customer: crowd_pledge.stripe_customer_id,
      payment_method_types: available_payment_methods(crowd_pledge),
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

    crowd_pledge.update(stripe_payment_intent_id: payment_intent.id)

    CrowdCampaignMailer.crowd_pledge_debited(crowd_pledge).deliver_later

    { success: true }
  rescue Stripe::CardError
    crowd_pledge.update(status: 'failed')
    CrowdCampaignMailer.crowd_pledge_failed(crowd_pledge).deliver_later

    { success: false, error: "Deine Zahlung ist fehlgeschlagen, bitte versuche es erneut." }
  end

  def payment_succeeded(crowd_pledge, payment_intent)
    crowd_pledge.update(status: 'debited', debited_at: Time.current)

    # Maybe send crowd_pledge_debited email here?
    { success: true }
  end

  def payment_failed(crowd_pledge, payment_intent)
    return if !crowd_pledge.processing?

    crowd_pledge.update(status: 'failed')
    CrowdCampaignMailer.crowd_pledge_failed(crowd_pledge).deliver_later

    { success: true }
  end

  def create_payment_intent(crowd_pledge)
    stripe_customer_id = get_stripe_customer_id(crowd_pledge)
    Stripe::PaymentIntent.create(
      customer: stripe_customer_id,
      amount: (crowd_pledge.total_price * 100).to_i,
      currency: 'eur',
      statement_descriptor: statement_descriptor(crowd_pledge.crowd_campaign),
      payment_method_types: available_payment_methods(crowd_pledge),
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
      status: 'processing',
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

  def available_payment_methods(crowd_pledge)
    if crowd_pledge.total_price <= 200 && crowd_pledge.crowd_campaign.completed?
      ['card', 'sepa_debit', 'sofort']
    elsif crowd_pledge.crowd_campaign.completed?
      ['card', 'sofort']
    elsif crowd_pledge.total_price <= 200
      ['card', 'sepa_debit']
    else
      ['card']
    end
  end

  def payment_method_last4(payment_method)
    if payment_method.type == 'card'
      payment_method.card.last4
    elsif payment_method.type == 'sepa_debit'
      payment_method.sepa_debit.last4
    end
  end

  def statement_descriptor(crowd_campaign)
    "#{crowd_campaign.region.host_id} Crowdfunding".upcase
  end

end
