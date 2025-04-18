class CrowdCampaignService

  def start(campaign)
    campaign.update(status: :funding)
    ActionProcessor.track(campaign, :create)
    CrowdCampaignMailer.funding_started(campaign).deliver_now
  end

  def complete(campaign)
    campaign.update(status: :completed)

    if campaign.successful?
      if campaign.boost_authorized?
        campaign.crowd_boost_pledges.authorized.update_all(status: 'debited', debited_at: Time.current)
        campaign.update(boost_status: 'boost_debited', transfer_status: 'payout_waiting')
      else
        campaign.update(transfer_status: 'payout_waiting')
      end
      campaign.crowd_pledges.authorized.find_each do |pledge|
        CrowdPledgeService.new.delay.charge(pledge)
      end
      campaign.crowd_donation_pledges.find_each do |pledge|
        CrowdCampaignMailer.crowd_donation_pledge_success(pledge).deliver_later
      end
      CrowdCampaignMailer.completed_successful(campaign).deliver_later
    else
      campaign.crowd_pledges.authorized.update_all(status: 'canceled')
      if campaign.boost_authorized? || campaign.boost_approved?
        campaign.crowd_boost_pledges.authorized.update_all(status: 'canceled')
        campaign.update(boost_status: 'boost_cancelled')
      end
      CrowdCampaignMailer.completed_unsuccessful(campaign).deliver_later
    end
  end

  def close(campaign)
    invoice_number = "#{Date.current.year}_Crowdfunding-#{campaign.id}_Nr-#{CrowdCampaign.next_invoice_number}"
    campaign.update(invoice_number: invoice_number, transfer_status: 'payout_ready')
    generate_invoice(campaign)
    CrowdCampaignMailer.invoice(campaign).deliver_now
  end

  def payout(campaign)
    Rails.logger.info "[CrowdCampaign Payout] Start payout process for campaign ##{campaign.id}, payout_ready?: #{campaign.payout_ready?}"
  
    return :failed unless campaign.payout_ready?
  
    payout_amount = (campaign.crowd_pledges_payout * 100).to_i
    payout_destination = campaign.user.stripe_connect_account_id

    metadata = {
      type: 'CrowdCampaign',
      campaign_id: campaign.id,
      invoice_number: campaign.invoice_number
    }

    if campaign.boosted?
      metadata[:crowd_boost_id] = campaign.crowd_boost&.id
      metadata[:crowd_boost_pledge_id] = campaign.crowd_boost_pledges.initialized.last&.id
      metadata[:crowd_boost_pledge_amount] = campaign.crowd_boost_pledges_sum
    end

    metadata.compact!
  
    begin
      transfer = Stripe::Transfer.create(
        {
          amount: payout_amount,
          currency: 'eur',
          destination: payout_destination,
          metadata: metadata
        },
        {
          idempotency_key: "crowd_campaign_#{campaign.id}_transfer"
        }
      )
  
      if transfer.id.present? && !transfer.reversed
        campaign.update!(
          transfer_status: 'payout_processing', 
          stripe_payout_transfer_id: transfer.id,
          payout_attempted_at: Time.current
        )
        Rails.logger.info "[CrowdCampaign Payout] Processing payout, Transfer-ID: #{transfer.id}, Campaign-ID: #{campaign.id}"  
          
        return :success
      end
  
    rescue Stripe::StripeError => e
      Rails.logger.error "[CrowdCampaign Payout] Stripe API error: #{e.class} - #{e.message}"
      campaign.update(transfer_status: 'payout_failed', payout_error_message: e.message)
    rescue StandardError => e
      Rails.logger.error "[CrowdCampaign Payout] Unexpected error: #{e.class} - #{e.message}"
      campaign.update(transfer_status: 'payout_failed', payout_error_message: e.message)
    end

    :failed
  end  

  def generate_invoice(campaign)
    invoice = CrowdCampaignInvoice.new.invoice(campaign)
    campaign.invoice.put(body: invoice)
  end

  def manual_boost(campaign)
    case campaign.check_boosting
    when :boost_authorized
      boost_amount = campaign.crowd_boost_slot.calculate_boost(campaign)
      crowd_boost_pledge = CrowdBoostPledge.create(
        amount: boost_amount,
        status: "authorized",
        crowd_campaign_id: campaign.id,
        crowd_boost_id: campaign.crowd_boost.id,
        crowd_boost_slot_id: campaign.crowd_boost_slot.id,
        region_id: campaign.region_id
      )
      if crowd_boost_pledge
        campaign.update(boost_status: 'boost_authorized')
        ActionProcessor.track(crowd_boost_pledge, :create)
      end
    end
  end

end
