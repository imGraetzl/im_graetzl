class CrowdCampaignService

  def start(campaign)
    campaign.update(status: :funding)
    ActionProcessor.track(campaign, :create)
    CrowdCampaignMailer.funding_started(campaign).deliver_now
  end

  def complete(campaign)
    campaign.update(status: :completed)

    if campaign.successful?
      campaign.crowd_pledges.authorized.find_each do |pledge|
        CrowdPledgeService.new.delay.charge(pledge)
      end
      campaign.crowd_donation_pledges.find_each do |pledge|
        CrowdCampaignMailer.crowd_donation_pledge_success(pledge).deliver_later
      end
      if campaign.boost_authorized?
        campaign.crowd_boost_pledges.authorized.update_all(status: 'debited', debited_at: Time.current)
        campaign.update(boost_status: 'boost_debited')
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
    campaign.update(invoice_number: invoice_number)
    generate_invoice(campaign)
    CrowdCampaignMailer.invoice(campaign).deliver_now
  end

  def generate_invoice(campaign)
    invoice = CrowdCampaignInvoice.new.invoice(campaign)
    campaign.invoice.put(body: invoice)
  end

end
