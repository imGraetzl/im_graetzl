class CrowdDonationPledgesController < ApplicationController
  def new
    @crowd_donation_pledge = CrowdDonationPledge.new(initial_donation_pledge_params)
    redirect_back fallback_location: @crowd_donation_pledge.crowd_donation.crowd_campaign, flash: {error: "Die Kampagne befindet sich gerade nicht im Finanzierungszeitraum (#{@crowd_donation_pledge.crowd_donation.crowd_campaign.runtime}) und kann daher jetzt nicht unterstützt werden."} and return if !@crowd_donation_pledge.crowd_donation.crowd_campaign.funding?

    @crowd_donation_pledge.assign_attributes(current_user_params) if current_user
    @donation_type = @crowd_donation_pledge.crowd_donation.donation_type
  end

  def create
    @crowd_donation_pledge = CrowdDonationPledge.new(crowd_donation_pledge_params)
    redirect_to @crowd_donation_pledge.crowd_donation.crowd_campaign, flash: {error: "Die Kampagne befindet sich gerade nicht im Finanzierungszeitraum (#{@crowd_donation_pledge.crowd_donation.crowd_campaign.runtime}) und kann daher jetzt nicht unterstützt werden."} and return if !@crowd_donation_pledge.crowd_donation.crowd_campaign.funding?

    @crowd_donation_pledge.user_id = current_user.id if current_user
    if @crowd_donation_pledge.save
      @crowd_donation_pledge.crowd_donation.increment!(:claimed)
      redirect_to [:summary, @crowd_donation_pledge]
      CrowdCampaignMailer.crowd_donation_pledge_info(@crowd_donation_pledge).deliver_later
      ActionProcessor.track(@crowd_donation_pledge, :create)
    else
      render :new
    end
  end

  def choice
    @crowd_donation_pledge = CrowdDonationPledge.new(initial_donation_pledge_params)
    @donation_type = @crowd_donation_pledge.crowd_donation.donation_type
  end

  def login
    @crowd_donation_pledge = CrowdDonationPledge.new(initial_donation_pledge_params)
    @donation_type = @crowd_donation_pledge.crowd_donation.donation_type
  end

  def summary
    @crowd_donation_pledge = CrowdDonationPledge.find(params[:id])
    @donation_type = @crowd_donation_pledge.crowd_donation.donation_type
  end

  def details
    @crowd_donation_pledge = CrowdDonationPledge.find(params[:id])
    @crowd_donation = @crowd_donation_pledge.crowd_donation
    @donation_type = @crowd_donation.donation_type
  end

  private

  def initial_donation_pledge_params
    params.permit(:crowd_campaign_id, :crowd_donation_id, :answer)
  end

  def current_user_params
    {
      email: current_user.email,
      contact_name: current_user.full_name,
    }
  end

  def crowd_donation_pledge_params
    params.require(:crowd_donation_pledge).permit(
      :crowd_campaign_id, :crowd_donation_id, :answer,
      :email, :contact_name,
    )
  end

end
