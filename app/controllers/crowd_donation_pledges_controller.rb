class CrowdDonationPledgesController < ApplicationController
  before_action :load_active_campaign, only: [:new, :create, :choice, :login]
  before_action :ensure_valid_donation!, only: [:new, :choice, :login]
  rate_limit to: 5, within: 30.minutes, only: [:create]

  def new
    @crowd_donation_pledge.assign_attributes(current_user_params) if current_user
  end

  def create
    @crowd_donation_pledge = @crowd_campaign.crowd_donation_pledges.build(crowd_donation_pledge_params)
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
    
  end

  def login

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

  def load_active_campaign
    redirect_to root_url and return if params[:crowd_campaign_id].blank?

    @crowd_campaign = CrowdCampaign.find(params[:crowd_campaign_id])

    if !@crowd_campaign.funding?
      redirect_back fallback_location: @crowd_campaign, flash: {
        error: "Die Kampagne befindet sich gerade nicht im Finanzierungszeitraum (#{@crowd_campaign.runtime}) und kann daher jetzt nicht unterstützt werden."
      }
    end
  end

  def ensure_valid_donation!
    @crowd_donation_pledge ||= @crowd_campaign.crowd_donation_pledges.build(initial_donation_pledge_params)

    unless @crowd_campaign.crowd_donations.exists?(id: @crowd_donation_pledge.crowd_donation_id)
      flash[:error] = "Ausgewählte Material-, Zeit- oder Raumspende konnte nicht gefunden werden."
      redirect_to @crowd_campaign and return
    end

    @donation_type = @crowd_donation_pledge.crowd_donation.donation_type
  end

  def initial_donation_pledge_params
    params.permit(:crowd_donation_id, :answer)
  end

  def current_user_params
    {
      email: current_user.email,
      contact_name: current_user.full_name,
    }
  end

  def crowd_donation_pledge_params
    params.require(:crowd_donation_pledge).permit(
      :crowd_donation_id, :answer, :email, :contact_name,
    )
  end

end
