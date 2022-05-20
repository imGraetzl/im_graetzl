class CrowdPledgesController < ApplicationController
  before_action :load_active_campaign, on: [:new, :create, :calculate_price, :choose_amount]

  def new
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.assign_attributes(current_user_params) if current_user
    @crowd_pledge.calculate_price
  end

  def create
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(crowd_pledge_params)

    if @crowd_pledge.crowd_reward&.fully_claimed?
      redirect_to @crowd_pledge.crowd_campaign, notice: "Dieses Dankeschön ist nicht mehr verfügbar."
    end

    @crowd_pledge.user_id = current_user.id if current_user
    @crowd_pledge.calculate_price
    @crowd_pledge.status = "incomplete"

    if @crowd_pledge.save
      redirect_to [:choose_payment, @crowd_pledge]
    else
      render :new
    end
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def choose_amount
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def login
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def choose_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:summary, @crowd_pledge] and return if !@crowd_pledge.incomplete?

    @crowd_pledge.calculate_price
    @setup_intent = CrowdPledgeService.new.create_setup_intent(@crowd_pledge)
  end

  def payment_authorized
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:choose_payment, @crowd_pledge] if params[:setup_intent].blank?

    success, error = CrowdPledgeService.new.payment_authorized(@crowd_pledge, params[:setup_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
      redirect_to [:summary, @crowd_pledge]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @crowd_pledge]
    end
  end

  def summary
    @crowd_pledge = CrowdPledge.find(params[:id])
  end

  def details
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to @crowd_pledge.crowd_campaign if @crowd_pledge.incomplete?
  end

  def change_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:summary, @crowd_pledge] if !@crowd_pledge.failed?

    @payment_intent = CrowdPledgeService.new.create_payment_intent(@crowd_pledge)
  end

  def payment_changed
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:summary, @crowd_pledge] if params[:payment_intent].blank?

    success, error = CrowdPledgeService.new.payment_retried(@crowd_pledge, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
      redirect_to [:summary, @crowd_pledge]
    else
      flash[:error] = error
      redirect_to [:change_payment, @crowd_pledge]
    end
  end

  private

  def load_active_campaign
    redirect_to crowd_campaigns_url and return if params[:crowd_campaign_id].blank?

    @crowd_campaign = CrowdCampaign.find(params[:crowd_campaign_id])

    if !@crowd_campaign.funding?
      redirect_back fallback_location: @crowd_campaign, flash: {
        error: "Die Kampagne befindet sich gerade nicht im Finanzierungszeitraum (#{@crowd_campaign.runtime}) und kann daher jetzt nicht unterstützt werden."
      }
    end
  end

  def initial_pledge_params
    params.permit(:crowd_reward_id, :donation_amount, :answer)
  end

  def current_user_params
    {
      email: current_user.email,
      contact_name: current_user.full_name,
      address_street: current_user.address_street,
      address_zip: current_user.address_zip,
      address_city: current_user.address_city,
    }
  end

  def crowd_pledge_params
    params.require(:crowd_pledge).permit(
      :crowd_reward_id, :donation_amount, :anonym, :terms,
      :email, :contact_name, :address_street, :address_zip, :address_city, :answer
    )
  end

end
